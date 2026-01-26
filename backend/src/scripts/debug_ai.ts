
import dotenv from "dotenv";
dotenv.config();

import { GoogleGenerativeAI } from "@google/generative-ai";

async function debugAI() {
  console.log("--- DEBUGGING GEMINI AI ---");
  
  const key = process.env.GEMINI_API_KEY;
  if (!key) {
      console.error("❌ GEMINI_API_KEY is missing in .env");
      process.exit(1);
  }
  console.log(`✅ API Key found (Length: ${key.length})`);

  try {
    const genAI = new GoogleGenerativeAI(key);
    console.log("Testing gemini-flash-latest...");
    const model = genAI.getGenerativeModel({ model: "gemini-flash-latest" });
    const result = await model.generateContent("Hello!");
    console.log("Success:", await result.response.text());
  } catch (error: any) {
    console.error("❌ AI Error:", error.message);
    if (error.response) {
        console.error("Details:", JSON.stringify(error.response, null, 2));
    }
  }
}

debugAI();
