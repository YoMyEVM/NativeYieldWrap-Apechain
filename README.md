# NativeYieldWrap-Apechain

This repository contains smart contracts for managing native yield delegation and staking vaults on the ApeChain network. The main components include:

---

## **WAPE9 Contract**
- **Description**: A separately deployed wrapped APE (WAPE) contract.
- **Features**:
  - Wraps native APE into ERC-20-compliant WAPE tokens.
  - Includes a **hard-coded native yield delegate address**, which automatically delegates the yield from native APE to a specified address.
- **Purpose**: Provides a mechanism to manage native APE yield delegation while enabling ERC-20 token compatibility.

---

## **Staking Vault**
- **Description**: An **ERC4626-compliant implementation** for staking vaults.
- **Features**:
  - Accepts ERC-20 tokens as staking assets.
  - Includes a **hard-coded native yield delegate address**, which delegates native yield to a predefined address.
  - Tracks shares and assets 1:1 in compliance with the ERC4626 standard.
- **Purpose**: Allows users to deposit supported assets, stake them, and delegate yield efficiently while maintaining compatibility with DeFi protocols.

---

## **Staking Vault Factory**
- **Description**: A factory contract to deploy new staking vaults.
- **Features**:
  - Deploys **custom staking vaults** with ERC4626 functionality.
  - Supports the deployment of a variety of vault configurations for different staking assets.
  - Automates the setup of yield delegation during deployment.

---

### **Usage**
1. **WAPE9**:
   - Deploy this contract separately for managing native APE wrapping and yield delegation.
2. **Staking Vault**:
   - Use for staking supported ERC-20 tokens with native yield delegation.
3. **Staking Vault Factory**:
   - Deploy the factory to create and manage multiple staking vaults dynamically.

---

### **Summary**
- **WAPE9**: Wraps native APE and delegates yield.
- **Staking Vault**: ERC4626 implementation with hard-coded yield delegation.
- **Factory**: Enables the deployment of a variety of staking vaults.

---

Feel free to contribute or open issues for improvements!
