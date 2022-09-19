//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

import "./Vaulttoken.sol";          //A ERC20 Token contract which has an IERC20 interface in it, aswwell as openzeppelins ownable.sol & context.sol

contract ownVault is Ownable {      
    IERC20 public DepositToken;     //We define our two tokens interacting with the contract
    IERC20 public VaultToken;       

    uint public totalSupply;
    mapping(address => uint) public balanceOf;
    mapping(address => uint) public depositDTAmount;            //Every person who deposits an amount can be called with their address showing the amount deposited(uint)
    mapping(address => uint) public depositVTAmount;

    constructor(address _DepositToken, address _VaultToken) {   //Deploying the contract with both of the token addresses
        DepositToken = IERC20(_DepositToken);
        VaultToken = IERC20(_VaultToken);
    }

    function _mint(address _to, uint _shares) private {
        totalSupply += _shares;
        balanceOf[_to] += _shares;
    }

    function _burn(address _from, uint _shares) private {
        totalSupply -= _shares;
        balanceOf[_from] -= _shares;
    }


    function depositDepositToken(uint _amount) public payable {   
        uint shares;
        if (totalSupply == 0) {
            shares = _amount;
        } else {
            shares = (_amount * totalSupply) / DepositToken.balanceOf(address(this));
        }

        _mint(msg.sender, shares);                                                            //a deposit function, with a number as amuount(IERC) which is public and can be paid with(payable)
        DepositToken.transferFrom(msg.sender, address(this), _amount);                        //"DepositToken is the Token transfered so that ETH wont be associated with this function
        depositDTAmount[msg.sender] += _amount;                                               //when this function is called add the amount to the user at mapping
    }

    function depositVaultToken(uint _amount) public payable onlyOwner {
        VaultToken.transferFrom(msg.sender, address(this), _amount);
        depositVTAmount[msg.sender] += _amount;
    }
    
    function withdrawVaultToken(uint _shares) external {
        uint amount = (_shares * DepositToken.balanceOf(address(this))) / totalSupply;
        _burn(msg.sender, _shares);
        VaultToken.transfer(msg.sender, amount);
        depositVTAmount[msg.sender] -= amount;
    }

    function withdrawDepositToken(uint _amount) public onlyOwner {
        DepositToken.transferFrom(msg.sender, address(this), _amount);
        depositDTAmount[msg.sender] -= _amount;
    }
}






