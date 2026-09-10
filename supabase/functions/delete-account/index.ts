import "jsr:@supabase/functions-js/edge-runtime.d.ts";
import { createClient } from "npm:@supabase/supabase-js@2";

const corsHeaders = {
  "Access-Control-Allow-Origin": "*",
  "Access-Control-Allow-Headers":
    "authorization, x-client-info, apikey, content-type",
};

async function deleteRevenueCatCustomer(
  appUserId: string,
  secretApiKey: string,
): Promise<void> {
  const response = await fetch(
    `https://api.revenuecat.com/v1/subscribers/${encodeURIComponent(appUserId)}`,
    {
      method: "DELETE",
      headers: {
        Authorization: `Bearer ${secretApiKey}`,
        "Content-Type": "application/json",
      },
    },
  );

  // RevenueCat documents both 200 and 404 as successful, retry-safe
  // outcomes for an "ensure deleted" request.
  if (response.status === 200 || response.status === 404) return;

  console.error(
    "delete-account RevenueCat deletion failed",
    response.status,
  );
  throw new Error("Unable to delete RevenueCat customer");
}

Deno.serve(async (req: Request) => {
  if (req.method === "OPTIONS") {
    return new Response("ok", { headers: corsHeaders });
  }

  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const supabaseUrl = Deno.env.get("SUPABASE_URL");
  const anonKey = Deno.env.get("SUPABASE_ANON_KEY");
  const serviceRoleKey = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY");
  const revenueCatSecretApiKey = Deno.env.get("REVENUECAT_SECRET_API_KEY")
    ?.trim();
  const authorization = req.headers.get("Authorization");

  if (!supabaseUrl || !anonKey || !serviceRoleKey || !authorization) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  const userClient = createClient(supabaseUrl, anonKey, {
    global: { headers: { Authorization: authorization } },
    auth: { persistSession: false },
  });

  const { data: userData, error: userError } =
    await userClient.auth.getUser();
  const user = userData.user;

  if (userError || !user) {
    return new Response(JSON.stringify({ error: "Unauthorized" }), {
      status: 401,
      headers: { ...corsHeaders, "Content-Type": "application/json" },
    });
  }

  // Fail closed: deleting the Supabase identity while silently retaining the
  // RevenueCat customer would leave account-linked service-provider data
  // behind. The server-only credential must be configured before release.
  if (!revenueCatSecretApiKey) {
    console.error("delete-account RevenueCat server credential missing");
    return new Response(
      JSON.stringify({ error: "Account deletion service is not configured" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  try {
    // The signed-in Supabase UUID is also the custom RevenueCat App User ID.
    // Request RevenueCat erasure first. If Supabase deletion later fails, a
    // retry is safe because RevenueCat treats an already-missing customer as
    // successful deletion.
    await deleteRevenueCatCustomer(user.id, revenueCatSecretApiKey);
  } catch (error) {
    console.error(
      "delete-account external data deletion failed",
      error instanceof Error ? error.message : "unknown error",
    );
    return new Response(
      JSON.stringify({ error: "Unable to delete account data" }),
      {
        status: 502,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  const adminClient = createClient(supabaseUrl, serviceRoleKey, {
    auth: { persistSession: false },
  });

  const { error: deleteError } =
    await adminClient.auth.admin.deleteUser(user.id);

  if (deleteError) {
    console.error("delete-account failed", deleteError.message);
    return new Response(
      JSON.stringify({ error: "Unable to delete account" }),
      {
        status: 500,
        headers: { ...corsHeaders, "Content-Type": "application/json" },
      },
    );
  }

  return new Response(JSON.stringify({ deleted: true }), {
    status: 200,
    headers: { ...corsHeaders, "Content-Type": "application/json" },
  });
});
