## Week 8 HW

### My First Rug Pull

* 請 clone 這份 [合約](https://github.com/HappyFeet07/RugPullHW/tree/master)
* 試圖在 test 中升級後 rug pull 搶走所有 user 的 usdc 和 usdt

### My Second Rug Pull

* 請假裝你是 [USDC](https://etherscan.io/address/0xa0b86991c6218b36c1d19d4a2e9eb0ce3606eb48#code) 的 Owner，嘗試升級 usdc，並完成以下功能
  * USDC Admin address ：0x807a96288a1a408dbc13de2b1d087d10356395d2
  * 製作一個白名單
  * 只有白名單內的地址可以轉帳
  * 白名單內的地址可以無限 mint token
  * 如果有其他想做的也可以隨時加入

### forge version

`forge 0.2.0 (87283bc 2023-10-06T00:32:37.923803000Z)`

### Install

```
$ forge install
```

### Test My First Rug Pull

```
$ forge test --mc TradingCenterTest
```

### Test My Second Rug Pull

* 請先在 project level 建立一個 `.env ` 檔案，檔案內容需包含底下資訊，並請將 ETHEREUM_MAINNET_RPC_URL 的地址換成你的 infura 地址

```
ETHEREUM_MAINNET_RPC_URL = '<your_infura_url>'
BLOCK_NUMBER = 18454357
```

```
$ forge test --mc UscdV3Test
```
