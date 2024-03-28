<h1 align="center"><a href="https://dylanlangston.com/">dylanlangston.com</a></h1>
<p align="center">
  <strong>The source code for my personal website. <u>🚧 Currently under construction. 🚧</u></strong>
</p>

<p align="center">
  <a href="https://ziglang.org/download"><img alt="Zig" src="https://img.shields.io/badge/Zig-Master-fd9930.svg"></a>
  <a href="https://www.raylib.com/"><img alt="Zig" src="https://img.shields.io/badge/raylib-Master-%23FFF.svg"></a>
  <a href="https://github.com/dylanlangston/dylanlangston.com/actions/workflows/OnPush.yml"><img alt="GitHub Workflow CI/CD" src="https://img.shields.io/github/actions/workflow/status/dylanlangston/dylanlangston.com/OnPush.yml?label=CI%2FCD"></a>
  <a href="https://github.com/dylanlangston/dylanlangston.com/blob/main/LICENSE"><img alt="GitHub License" src="https://img.shields.io/github/license/dylanlangston/dylanlangston.com?label=License"></a>
  <a href="https://github.com/dylanlangston/dylanlangston.com/releases/latest"><img alt="Latest Build" src="https://img.shields.io/badge/dynamic/json?url=https%3A%2F%2Fapi.github.com%2Frepos%2Fdylanlangston%2Fdylanlangston.com%2Freleases&query=%24%5B%3A1%5D.tag_name&label=Latest%20Build&color=%234c1"></a>
  <a href="https://api.github.com/repos/dylanlangston/dylanlangston.com"><img alt="GitHub repo size" src="https://img.shields.io/github/repo-size/dylanlangston/dylanlangston.com?label=Repo%20Size"></a>
</p>

## Overview 👀

My personal website is built with a modern tech stack to ensure performance and flexibility. It utilizes the following technologies:
- [🇿 Zig](https://ziglang.org/) and [🎮 raylib](https://www.raylib.com/) for client-side rendering.
- [🌐 Emscripten](https://emscripten.org/) for compiling to [🕸️ WebAssembly](https://webassembly.org/).
- [🛠️ Binaryen](https://github.com/WebAssembly/binaryen) for optimizing WebAssembly.
- [🦀 Rust](https://www.rust-lang.org/) for backend logic utilizing [🔢 AWS Lambda](https://aws.amazon.com/lambda/).
- [🖥️ Svelte](https://svelte.dev/) for building interactive user interfaces.
- [📝 TypeScript](https://www.typescriptlang.org/) for improving JavaScript code reliability and developer efficiency.
- [🎨 TailwindCSS](https://tailwindcss.com/) for styling components with utility-first CSS.
- [🚀 Vite](https://vitejs.dev/) for fast development and optimized production builds.
- Hosted on [🌍 AWS S3](https://aws.amazon.com/s3/) and distributed globally via [☁️ AWS CloudFront](https://aws.amazon.com/cloudfront/) for high availability and scalability.
- [📦 SAM CLI](https://github.com/aws/aws-sam-cli) for deploying serverless applications.

```mermaid
flowchart TB
    subgraph "Frontend - Static Site"
        direction LR
        S1("Svelte")
        S2("Typescript")
        S3("Tailwindcss")
        S4("Vite")
        S5("AWS S3")
        S6("AWS CloudFront")

        subgraph "HTML 5 Canvas"
            direction LR
            A1("Zig")
            A2("Raylib")
            A3(Emscripten)
            A4("Binaryen")
            A1 -.C Interop.- A2 -.- A3
            A1 -.WebAssembly.- A3
            A3 ==Optimize==> A4
        end

        S3 -.- S1 -.- S2 -.- S3 -.- subGraph0 -.- S2
        S1 -.- subGraph0
        S1 & S2 & S3 & subGraph0 --Bundle--> S4 ==Hosting==> S5 ==CDN==> S6
    end

    subgraph "Backend - API"
        direction LR
        I1("Rust")
        I2("Cargo Lambda")
        I3("AWS Lambda")
        I4("AWS API Gateway")
        I5("AWS SES")

        I1 -.- I2 -.- I3 --> I4
        I3 -.- I5 -.- I2
    end

	subGraph1 <-..-> subGraph2
	
```

## Build Process 🏗️

The build process for my personal website involves the following steps:
1. **Development Environment Setup:** Use Docker for consistent environment setup across different machines. GitHub Actions can be integrated for automation.
2. **Code Compilation:** Utilize Rust for server-side code and Zig/Emscripten along with Svelte/TypeScript for client-side code.
3. **Optimization:** Optimize compiled assets for production using Binaryen and Vite to ensure minimal file sizes and optimal performance.
4. **Deployment:** Deploy optimized assets to AWS S3 and configure CloudFront for global content distribution using SAM CLI.

<!-- https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams -->
<!-- https://mermaid.js.org/syntax/flowchart.html -->
```mermaid
flowchart LR
	B1("Makefile")
	

	B7("Docker")
	B8("Github Actions")
	B9("AWS SAM CLI")
    subgraph "HTML 5 Canvas"
        B2("Zig")
        B3("Emscripten")
        B4("Binaryen")
    end
    subgraph "Static Site"
        B12("Svelte")
        B13("TypeScript")
        B5("NodeJS/Bun")
        B6("Vite")
    end
    subgraph "API "
        B10("rust")
        B11("cargo")
    end


    B2 -.- B3 -.- B4
    B5 -.- B6
    B10 -.- B11
    B13 -.- B12
    B5 -.- B12
    B13 -.- B5

    B1 --Build--> subGraph0 --Build--> subGraph1 --Build--> subGraph2 --Release--> B9
    B8 --Dev Container--> B7 --Setup--> B1
    B8 ~~~ B9
    B8 ~~~ B1
    B8 ~~~ subGraph0

```

### Dev Environment 💻
This repository includes a *[devcontainer.json](.devcontainer/devcontainer.json)* to get up and running quickly with a full-featured development environment in the cloud![^local-development]

[![Open in GitHub Codespaces](https://img.shields.io/static/v1?style=flat&label=GitHub+Codespaces&message=Open&color=lightgrey&logo=github)](https://codespaces.new/dylanlangston/dylanlangston.com)
[![Open in Dev Container](https://img.shields.io/static/v1?style=flat&label=Dev+Container&message=Open&color=blue&logo=visualstudiocode)](https://vscode.dev/redirect?url=vscode://ms-vscode-remote.remote-containers/cloneInVolume?url=https://github.com/dylanlangston/dylanlangston.com)

## Credits 🙌

The website design and development is the singular effort of [@dylanlangston](https://github.com/dylanlangston). Closed for contributions but feel free to fork or open an issue if you have a question!

## License 📜
This tool is licensed under the [MIT License](https://opensource.org/licenses/MIT). See the [`LICENSE`](LICENSE) file for details.

[^local-development]: For local development check out [Dev Containers](https://marketplace.visualstudio.com/items?itemName=ms-vscode-remote.remote-containers) and [DevPod](https://devpod.sh/).
