import { Context, Next } from "hono";
import { JwtPayload } from "jsonwebtoken";

export function authorize(
  ...roles: string[]
) {

  return async (
    c: Context,
    next: Next,
  ) => {

    const payload = c.get("jwt" as never) as JwtPayload;

    const role =
      payload?.role;

    if (
      !role ||
      !roles.includes(role)
    ) {

      return c.json(
        {
          message:
            "Forbidden",
        },
        403,
      );
    }

    await next();
  };
}
