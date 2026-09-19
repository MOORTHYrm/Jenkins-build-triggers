# Scripted Pipeline — Report Generator Demo

This folder demonstrates two core Scripted Pipeline concepts using a simple
"report generator" example: **Groovy basics** and the **node block**.

---

## 1. Groovy Basics (plain data, before any agent is allocated)

In Scripted Pipeline, you can define configuration as real Groovy data —
lists, maps, and functions — instead of the flat strings Declarative
Pipeline's `environment {}` block forces on you.

```groovy
def REPORT_NAME = 'nightly-report'
def OUTPUT_FORMATS = ['pdf', 'csv', 'json']
def DATA_SOURCES = [
    sales:     'https://internal.example.com/api/sales',
    inventory: 'https://internal.example.com/api/inventory',
    support:   'https://internal.example.com/api/support'
]

def buildFilename(String format) {
    return "${REPORT_NAME}.${format}"
}
```

- `OUTPUT_FORMATS` is a real Groovy **list** — no need to split a comma-separated string later.
- `DATA_SOURCES` is a real **map** — addressable directly as `DATA_SOURCES.sales`.
- `buildFilename()` is a genuine **function**, reusable anywhere later in the script.

This code runs fine on its own, **outside** any `node` block — plain Groovy
and `echo` execute at the top level of a Scripted Pipeline.

---

## 2. Node Block (allocating a real machine)

Plain Groovy logic can run anywhere, but anything that touches the
filesystem or runs a shell command needs an actual machine underneath it.
That's what `node` provides.

```groovy
node('linux') {
    echo "Running on ${env.NODE_NAME}, workspace: ${env.WORKSPACE}"

    checkout scm

    echo "Report '${REPORT_NAME}' will be generated in formats: ${OUTPUT_FORMATS.join(', ')}"
}
```

- `node('linux')` — claims a Jenkins agent labeled `linux` and creates a workspace on it.
- `env.NODE_NAME` — the name of the machine that got assigned.
- `env.WORKSPACE` — the workspace folder path created for this build.
- `checkout scm` — pulls the repo's source code into that workspace. **Requires an agent.**

### Quick experiment (try it yourself)

| Step | Move it outside `node`? | Result |
|---|---|---|
| `echo "Report '${REPORT_NAME}'..."` | Yes | ✅ Still works — plain Groovy, no filesystem needed |
| `checkout scm` | Yes | ❌ Fails — requires an agent/workspace to run |

This is the core rule of Scripted Pipeline:

> **If a step just computes or prints something → it can run anywhere.**
> **If a step touches files, Git, or a shell command → it needs a `node` block.**

---

## How to run this demo

1. Create a Pipeline job in Jenkins → Pipeline script from SCM → point it at this repo.
2. Set the Script Path to `scripted-pipeline-demo/Jenkinsfile`.
3. Make sure you have an agent labeled `linux` (or change the label in the file to match one you have).
4. Run the build and check the console output — you should see:
   ```
   Running on <agent-name>, workspace: <workspace-path>
   Report 'nightly-report' will be generated in formats: pdf, csv, json
   ```

## Use cases this pattern supports

- Running builds on a specific OS/environment (`node('linux')`, `node('windows')`, `node('docker')`)
- Checking out source code before running any build/test/deploy logic
- Keeping cheap logic (config, string building) outside `node` to avoid wasting agent slots
- Running parallel stages across different agents in the same pipeline
- Freeing up shared/limited agent pools faster by scoping `node` tightly
- Debugging "no executor available" errors caused by filesystem steps placed outside `node`

