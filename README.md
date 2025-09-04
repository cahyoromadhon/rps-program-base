# RockPaperScissors NFT Game

A simple **Rock-Paper-Scissors** smart contract on Base Sepolia. Players can:

- Create and join games
- Submit moves
- Automatically determine winners
- Redeem NFTs for victories

---

## 🛠️ Prerequisites

You will need:

- **Windows with WSL (Ubuntu recommended)** or Linux
- **Git**
- **Foundry** (Forge + Cast)

---

## ⚡ Step 1: Install WSL (Windows only)

1. Open **PowerShell** as Administrator
2. Run:
   ```bash
   wsl --install -d Ubuntu
   ```
3. Restart your computer
4. Open **Ubuntu** from your Start Menu

If you’re already on Linux, skip this step.

---

## ⚡ Step 2: Install Foundry

Inside **Ubuntu/WSL/Linux** terminal:

```bash
curl -L https://foundry.paradigm.xyz | bash
```

Then reload your shell:

```bash
source ~/.bashrc
```

Finally, install Foundry tools:

```bash
foundryup
```

Check installation:

```bash
forge --version
cast --version
```

---

## ⚡ Step 3: Clone the Project

```bash
git clone https://github.com/cahyoromadhon/rps-program-base.git
cd rps-contract
```

---

## ⚡ Step 4: Build & Test

```bash
forge build
forge test
forge test -vvvv
```

---

## ⚡ Step 5: Deploy to Base Sepolia

Set your RPC and wallet:

```bash
cast wallet import <your-wallet-name> --private-key YOUR_PRIVATE_KEY_HERE
cast wallet list
export PRIVATE_KEY=$(cast wallet private-key --account <your-wallet-name>)

```

Deploy:

```bash
forge script script/RPSGame.s.sol \
  --rpc-url https://sepolia.base.org/ \
  --broadcast \
  --account <your-wallet-name>
```

---

## ⚡ Step 6: Verify on BaseScan

1. Get Etherscan API Key from: https://etherscan.io/login
2. Put the API key on .env with name 'ETHERSCAN_API_KEY=<your-key>'

```bash
forge verify-contract \
  <your-deployed-contract> \
  src/RPSGame.sol:RockPaperScissors \
  --chain 84532 \
  --verifier sourcify \
  --constructor-args $(cast abi-encode "constructor(address)" $(cast wallet address --account <your-wallet-name>))
```

---

## ⚡ Check on Base Sepolia Explorer

```bash
https://sepolia.basescan.org/
```

---

## 📜 License

MIT
