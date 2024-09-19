const esbuild = require("esbuild");

async function build() {
  const context = await esbuild.context({
    entryPoints: ["frontend/src/index.js"],
    bundle: true,
    outfile: "frontend/javascript/index.js",
    loader: {
      '.js': 'jsx',
    },
    jsxFactory: "React.createElement",
    jsxFragment: "React.Fragment",
    minify: true,
  });

  if (process.argv.includes("--watch")) {
    await context.watch();
  } else {
    await context.rebuild();
    await context.dispose();
  }
}

build().catch(() => process.exit(1));
