const esbuild = require("esbuild");

// esbuild.build({
//   entryPoints: ["frontend/src/index.js"],
//   bundle: true,
//   outdir: "frontend/javascript/index.js",
//   loader: {
//     '.js': 'jsx',
//   },
//   jsxFactory: "React.createElement",
//   jsxFragment: "React.Fragment",
//   minify: true,
//   watch: process.argv.includes("--watch"),
// }).catch(() => process.exit(1));
//

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
