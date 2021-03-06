pragma solidity ^0.4.21;


import "./Owned.sol";

contract MoneyManager is Owned {

    event LogMoneyAdded(address sender, uint value);
    event LogMoneyWithdrawed(address sender, uint value);

    mapping(address => uint) public balance;

    modifier hasMoney(uint money)
    {
        require(balance[msg.sender] >= money);
        _;
    }

    function addMoney()
    public 
    payable
    {
        balance[msg.sender] += msg.value;
        emit LogMoneyAdded(msg.sender, msg.value);
    }

    function withdrawMoney(uint amount) 
    hasMoney(amount)
    public
    {
        balance[msg.sender] -= amount;        
        emit LogMoneyAdded(msg.sender, amount);
        msg.sender.transfer(amount);
    }
    

}