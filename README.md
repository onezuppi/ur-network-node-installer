# Urnetwork easy installer

Universal Bash script to automatically deploy the **URnetwork Provider** with docker.

## ✨ Features

- Automatically installs **curl** if it is missing  
- Installs **Docker Compose** using the [onezuppi/install-docker-sh](https://github.com/onezuppi/install-docker-sh) when required  
- Prompts for an `auth_code`, exchanges it for a `by_jwt` token via the BringYour API and stores it
- Generates a production‑ready **docker‑compose.yml** and launches the provider container  
- Works on popular Linux distributions

## 🚀 Quick install

### With **curl**

```bash
curl -fsSL https://raw.githubusercontent.com/onezuppi/ur-network-node-installer/refs/heads/main/install.sh | bash
```

### With **wget**

```bash
wget -qO- https://raw.githubusercontent.com/onezuppi/ur-network-node-installer/refs/heads/main/install.sh | bash
```

## 🖐 Manual install

```bash
git clone https://github.com/onezuppi/ur-network-node-installer
cd ur-network-node-installer
bash install.sh
```               


The container should appear with the status **Up**.

## 🧹 Uninstall

```bash
docker compose down
rm -rf urnetwork docker-compose.yml
```

## 📄 License

MIT
