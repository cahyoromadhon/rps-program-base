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
git clone https://github.com/yourusername/rps-contract.git
cd rps-contract
```

---

## ⚡ Step 4: Build & Test

```bash
forge build
forge test -vvvv
```

---

## ⚡ Step 5: Deploy to Base Sepolia

Set your RPC and wallet:

```bash
export BASE_SEPOLIA_RPC="https://sepolia.base.org"
export PRIVATE_KEY="your_private_key"
```

Deploy:

```bash
forge script script/RPSGame.s.sol --rpc-url $BASE_SEPOLIA_RPC --private-key $PRIVATE_KEY --broadcast
```

---

## ⚡ Step 6: Verify on BaseScan

1. Sign up at [BaseScan](https://sepolia.basescan.org/)
2. Get an API key
3. Export it:
   ```bash
   export ETHERSCAN_API_KEY=your_key_here
   ```

Then run:

```bash
forge verify-contract \
  0xYourContractAddress \
  src/RPSGame.sol:RockPaperScissors \
  --chain 84532 \
  --verifier etherscan \
  --verifier-url https://api-sepolia.basescan.org/api
```

---

## ⚡ Run Tests

```bash
forge test
```

---

## 📜 License

MIT
