// Setup type definitions for built-in Supabase Runtime APIs
import "@supabase/functions-js/edge-runtime.d.ts";
import { withSupabase } from "@supabase/server";

export default {
  fetch: withSupabase({ auth: ["secret"] }, async (req, ctx) => {
    // ユーザー自身のみが自分のアカウントを削除できるようにする
    const user = ctx.auth.user;
    if (!user) {
      return new Response("Unauthorized", { status: 401 });
    }

    const { user_id } = await req.json();

    // セキュリティチェック：トークンのユーザーIDと指定されたIDが一致することを確認
    if (user.id !== user_id) {
      return new Response("Forbidden", { status: 403 });
    }

    // ユーザー削除を実行 (Admin APIを使用)
    const { error } = await ctx.supabaseAdmin.auth.admin.deleteUser(user_id);

    if (error) {
      return new Response(JSON.stringify({ error: error.message }), { 
        status: 400,
        headers: { "Content-Type": "application/json" }
      });
    }

    return new Response(JSON.stringify({ message: "User deleted successfully" }), {
      status: 200,
      headers: { "Content-Type": "application/json" }
    });
  }),
};
