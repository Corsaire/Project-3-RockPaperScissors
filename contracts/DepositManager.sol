pragma solidity ^0.4.24;

contract DepositManager
{
    uint constant GATHERING_DEPOSITS_STATE = keccak256("GATHERING_DEPOSITS_STATE");
    uint state;
    uint stake;
    address[] players;
    mapping(uint => bool) deposited;
    uint depositedCount;


    modifier onlyState(uint _state)
    {
        require(_state == state);
        _;
    }

    construcor(address[] _players, uint _stake)
    {
        state = GATHERING_DEPOSITS_STATE;
        players = _players;
        stake = _stake;
    }

    function depositStake(uint index) 
    onlyState(GATHERING_DEPOSITS_STATE)
    payable
    {
        require(msg.value == stake);
        require(deposited[msg.sender] == false);
        require(players[index] == msg.sender);
        
        deposited[msg.sender] = true;
        depositedCount++;
    }

    function checkDeposited()
    returns(bool)
    {
        if(depositedCount < players.length)
            return false;
        assert(depositedCount == players.length);
        

    }    

}