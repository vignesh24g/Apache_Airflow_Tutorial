Here is a clean, structured version of the `README.md` rewritten as a direct, step-by-step instruction manual.

---

```markdown
# 🛠️ Apache Airflow Standalone Setup Guide

This guide outlines how to initialize a standardized, fully containerized development environment for Apache Airflow using **GitHub Codespaces**. This layout eliminates local virtual environment (`venv`) management and ensures an identical workspace for all contributors.

---

## 📅 Step 1: Create the Environment Configuration

At the root of your project directory, create a new folder named `.devcontainer/` and add the following two configuration files exactly as named.

### 1. Create `.devcontainer/Dockerfile`
This file defines the base system image and installs Apache Airflow using official production constraints.
* *Refer to the local file:* [`.devcontainer/Dockerfile`](./.devcontainer/Dockerfile)

### 2. Create `.devcontainer/devcontainer.json`
This file handles workspace orchestration, automatic port forwarding, and core environment variable overrides.
* *Refer to the local file:* [`.devcontainer/devcontainer.json`](./.devcontainer/devcontainer.json)

---

## 🚀 Step 2: Initialize and Build the Container

1. Save and commit both files to your GitHub repository.
2. Launch a new **GitHub Codespace** on your branch. The environment engine will automatically detect the configuration files and build your environment.
3. *Note: If you are already inside an active Codespace, press `Ctrl + Shift + P` (`Cmd + Shift + P` on macOS), search for **Codespaces: Rebuild Container**, and press Enter.*

---

## ⚡ Step 3: Run Airflow Standalone

1. Once the container build completes, open your integrated terminal inside VS Code and execute the startup command:
   ```bash
   airflow standalone
   

```

2. Wait for the engine to initialize. The script will automatically generate your default login credentials and safely write them to a local configuration directory.

---

## 🔑 Step 4: Authentication & UI Access

* **Default Username:** `admin`
* **Password Retrieval:** Open a separate terminal pane at any time and run the following command to retrieve your generated security key:
```bash
cat .airflow_home/standalone_admin_password.txt


```



```
* **Accessing the Dashboard:** Look for the VS Code port-forwarding popup in the bottom-right corner and click **Open in Browser** (or navigate to your editor's **Ports** tab and select the link for Port `8080`).

---

## 📂 Step 5: Developing Custom DAGs

* **Workspace Rule:** All pipeline orchestration code must be placed directly inside the root-level `dags/` folder. 
* **Live Synchronization:** The scheduler is explicitly configured to watch this root directory. Any Python DAG files you save there will compile and appear in your web browser interface instantly.

```

```

```
Refer setup_instructions.md for local setup
