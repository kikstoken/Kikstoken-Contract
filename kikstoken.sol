// SPDX-License-Identifier: MIT

pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract KiksToken is ERC20, Ownable {
    address public liquidityPool = 0x0409aB64298195720629100Ae01F1988E62DA53F; // Liquidity pool address
    address public feeRecipient; // Address to receive transfer fees
    uint256 public transferFee = 3; // Fee in percentage
    bool public tradingEnabled = false; // Trading state
    string public tokenLogo = "https://gateway.pinata.cloud/ipfs/bafkreic3glbaqxuw5jb7onxaqsvc36rdi42cgj5j6zmmbmqy46gw4qetui"; // URL of the token logo

    event FeePaid(address indexed sender, uint256 feeAmount);
    event TransferFeeChanged(uint256 oldFee, uint256 newFee);
    event TradingEnabled();
    event Received(address sender, uint256 amount);

    constructor(address initialOwner, address initialFeeRecipient) ERC20("KiksToken", "KIKS") Ownable(initialOwner) {
        require(initialOwner != address(0), "Zero address");
        require(initialFeeRecipient != address(0), "Invalid fee recipient");
        feeRecipient = initialFeeRecipient;
        _mint(initialOwner, 590_000_000_000_000 * 10 ** decimals()); // 590 trillion tokens minted
    }

    function decimals() public view virtual override returns (uint8) {
        return 18;
    }

    function enableTrading() external onlyOwner {
        require(!tradingEnabled, "Already enabled");
        tradingEnabled = true;
        emit TradingEnabled();
    }

    function setTransferFee(uint256 fee) external onlyOwner {
        require(fee <= 10, "Max 10%");
        emit TransferFeeChanged(transferFee, fee);
        transferFee = fee;
    }

    function setFeeRecipient(address newRecipient) external onlyOwner {
        require(newRecipient != address(0), "Invalid recipient");
        feeRecipient = newRecipient;
    }

    function setTokenLogo(string memory newLogo) external onlyOwner {
        tokenLogo = newLogo;
    }

    function transferWithFee(address recipient, uint256 amount) external returns (bool) {
        require(tradingEnabled, "Not enabled");
        require(recipient != address(0), "Invalid recipient");

        uint256 feeAmount = (amount * transferFee) / 100; // Fee calculation
        uint256 netAmount = amount - feeAmount;

        // Transfer fee to feeRecipient
        _transfer(_msgSender(), feeRecipient, feeAmount);
        emit FeePaid(_msgSender(), feeAmount);

        // Transfer remaining amount to recipient
        _transfer(_msgSender(), recipient, netAmount);
        return true;
    }

    receive() external payable {
        emit Received(msg.sender, msg.value);
    }
}
