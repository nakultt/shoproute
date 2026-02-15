// Minimal Node.js shims so TypeScript can compile in environments
// where `@types/node` may not be installed (CI/deploy). Add more
// declarations here only when necessary — keep these minimal.

declare namespace NodeJS {
  interface ProcessEnv {
    NODE_ENV?: 'development' | 'production' | 'test';
    GEMINI_API_KEY?: string;
    DATABASE_URL?: string;
    [key: string]: string | undefined;
  }

  interface Process {
    env: ProcessEnv;
    // common members used in this project
    stdout: any;
    stderr: any;
    // exit never returns — helps TS know code flow stops
    exit(code?: number): never;
  }
}

declare const process: NodeJS.Process;
