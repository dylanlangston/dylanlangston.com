# 🚧 Under Construction 🚧

This is the future source code for my personal website. Currently under construction.

<!-- https://docs.github.com/en/get-started/writing-on-github/working-with-advanced-formatting/creating-diagrams -->
<!-- https://mermaid.js.org/syntax/flowchart.html -->
```mermaid
---
title: Architecture Overview
---
flowchart TB
    subgraph "Static Site"
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

    subgraph "API"
        direction LR
        I1("Rust")
        I2("Cargo Lambda")
        I3("AWS Lambda")
        I4("AWS API Gateway")
        I5("AWS SNS")

        I1 -.- I2 -.- I3 --> I4
        I3 -.- I5 -.- I2
    end

	subGraph1 <-..-> API
	
```

```mermaid
---
title:  Build Process
---
flowchart LR
	B1("Makefile")
	

	B7("Docker")
	B8("Github Actions")
	B9("AWS CLI")
    subgraph "HTML 5 Canvas"
        B2("Zig")
        B3("Emscripten")
        B4("Binaryen")
    end
    subgraph "Static Site"
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

    B1 --Build--> subGraph0 --Build--> subGraph1 --Build--> subGraph2 --Release--> B9
    B8 --Dev Container--> B7 --Setup--> B1
    B8 ~~~ B9
    B8 ~~~ B1
    B8 ~~~ subGraph0

```
