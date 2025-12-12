import nodemailer from "nodemailer";

const transporter = nodemailer.createTransport({
  host: process.env.SMTP_HOST || "smtp.gmail.com",
  port: parseInt(process.env.SMTP_PORT || "587"),
  secure: false,
  auth: {
    user: process.env.SMTP_USER,
    pass: process.env.SMTP_PASS,
  },
});

export const generateOTP = (): string => {
  return Math.floor(100000 + Math.random() * 900000).toString();
};

export const sendVerificationEmail = async (
  to: string,
  otp: string,
  name: string
): Promise<boolean> => {
  try {
    const mailOptions = {
      from: process.env.SMTP_FROM || "ShopRoute <noreply@shoproute.com>",
      to,
      subject: "Verify Your Email - ShopRoute",
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style="font-family: 'Inter', -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; background-color: #F9FAFB; margin: 0; padding: 40px 20px;">
          <div style="max-width: 480px; margin: 0 auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
            <div style="background: linear-gradient(135deg, #2563EB, #1E40AF); padding: 32px; text-align: center;">
              <h1 style="color: white; margin: 0; font-size: 28px; font-weight: 700;">🛒 ShopRoute</h1>
              <p style="color: rgba(255,255,255,0.9); margin: 8px 0 0; font-size: 14px;">Shop Smarter, Route Faster</p>
            </div>
            <div style="padding: 32px;">
              <h2 style="color: #111827; margin: 0 0 16px; font-size: 20px;">Hi ${name}! 👋</h2>
              <p style="color: #6B7280; margin: 0 0 24px; line-height: 1.6;">
                Thanks for signing up for ShopRoute! Please use the verification code below to complete your registration:
              </p>
              <div style="background: #F3F4F6; border-radius: 12px; padding: 24px; text-align: center; margin-bottom: 24px;">
                <span style="font-size: 36px; font-weight: 700; letter-spacing: 8px; color: #2563EB;">${otp}</span>
              </div>
              <p style="color: #9CA3AF; font-size: 14px; margin: 0;">
                This code expires in 10 minutes. If you didn't request this, please ignore this email.
              </p>
            </div>
            <div style="background: #F9FAFB; padding: 20px; text-align: center; border-top: 1px solid #E5E7EB;">
              <p style="color: #9CA3AF; font-size: 12px; margin: 0;">© 2024 ShopRoute. All rights reserved.</p>
            </div>
          </div>
        </body>
        </html>
      `,
    };

    await transporter.sendMail(mailOptions);
    return true;
  } catch (error) {
    console.error("Email sending failed:", error);
    return false;
  }
};

export const sendPasswordResetEmail = async (
  to: string,
  otp: string,
  name: string
): Promise<boolean> => {
  try {
    const mailOptions = {
      from: process.env.SMTP_FROM || "ShopRoute <noreply@shoproute.com>",
      to,
      subject: "Reset Your Password - ShopRoute",
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
        </head>
        <body style="font-family: 'Inter', sans-serif; background-color: #F9FAFB; margin: 0; padding: 40px 20px;">
          <div style="max-width: 480px; margin: 0 auto; background: white; border-radius: 16px; overflow: hidden; box-shadow: 0 4px 6px rgba(0,0,0,0.05);">
            <div style="background: linear-gradient(135deg, #2563EB, #1E40AF); padding: 32px; text-align: center;">
              <h1 style="color: white; margin: 0; font-size: 28px;">🛒 ShopRoute</h1>
            </div>
            <div style="padding: 32px;">
              <h2 style="color: #111827; margin: 0 0 16px;">Password Reset Request</h2>
              <p style="color: #6B7280; margin: 0 0 24px;">
                Hi ${name}, we received a request to reset your password. Use this code:
              </p>
              <div style="background: #FEF2F2; border: 2px solid #FCA5A5; border-radius: 12px; padding: 24px; text-align: center; margin-bottom: 24px;">
                <span style="font-size: 36px; font-weight: 700; letter-spacing: 8px; color: #DC2626;">${otp}</span>
              </div>
              <p style="color: #9CA3AF; font-size: 14px; margin: 0;">
                This code expires in 10 minutes. If you didn't request this, your account is safe.
              </p>
            </div>
          </div>
        </body>
        </html>
      `,
    };

    await transporter.sendMail(mailOptions);
    return true;
  } catch (error) {
    console.error("Email sending failed:", error);
    return false;
  }
};
