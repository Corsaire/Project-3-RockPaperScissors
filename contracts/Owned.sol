pragma solidity ^0.4.18;

contract Owned {

    address public owner;
    event LogNewOwner(address sender, address newOwner);

    modifier onlyOwner() {
        require(owner == msg.sender);
        _;
    }

    function Owned() public {
        owner = msg.sender;
    }

    function changeOwner(address newOwner) public
    onlyOwner
    {
        require(newOwner!=0);
        owner = newOwner;
        LogNewOwner(msg.sender, newOwner);
    }
}