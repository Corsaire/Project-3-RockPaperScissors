pragma solidity ^0.4.6;

import "./Owned.sol";

contract RPS is Owned
{
    enum StateValues { DECISION, SALT, GAME_OVER, GAME_OVER_ALL_WITHDRAWED}
    enum DecisionValues { NONE, ROCK, PAPER, SCISSORS}

    struct Player
    {
        address addr;
        uint money;
        bytes32 encryptedDecision;
        DecisionValues decision;
        bytes32 salt;
    }

    uint constant DEADLINE_DEFAULT = 100;
    mapping(address => Player) public players;
    uint public deadline;
    Player[] playersArray;
    uint decisionsLeft;

    //0 - waiting for players decision
    //1 - waiting for salt
    //2 - game over
    //3 - game over and funds are withdrawed
    StateValues state = StateValues.DECISION;

    modifier hasMoney()
    {
        require(players[msg.sender].money>0);
        _;
    }
    
    function RPS(address[] addresses, uint[] money) 
    public
    { 
        for(uint i = 0; i < addresses.length; i++)
        {
            playersArray.push(Player({addr:addresses[i], money:money[i], encryptedDecision: 0, decision:DecisionValues.NONE, salt:0}));
            players[msg.sender] = playersArray[playersArray.length-1];
        }
    }
    
    function submitDecision(bytes32 encryptedDecision)
    hasMoney
    public 
    {
        require(state==StateValues.DECISION);
        require(block.number<=deadline);
        require(players[msg.sender].encryptedDecision==0);
        players[msg.sender].encryptedDecision = encryptedDecision;
        
        decisionsLeft--;
        if(decisionsLeft == 0)
        {
            decisionsLeft = playersArray.length;
            state = StateValues.SALT;
            deadline = block.number + DEADLINE_DEFAULT;
        }
    }

    function determineWinners() 
    public
    {
        for(uint i = 0; i < playersArray.length; i++)
        {

        }
    }

    function submitSalt(bytes32 salt, DecisionValues decision)
    public 
    hasMoney
    {
        Player storage p = players[msg.sender];
        require(state==StateValues.SALT);
        require(block.number<=deadline);
        require(p.salt==0);        
        require(keccak256(p.decision, p.salt) == p.encryptedDecision);
        p.salt = salt;
        p.decision = decision;

        decisionsLeft--;
        if(decisionsLeft == 0)
        {
            decisionsLeft = playersArray.length;
            state = StateValues.GAME_OVER;
            deadline = block.number + DEADLINE_DEFAULT;
        }
    }

    function getReward()
    hasMoney
    public
    {
        require(block.number>deadline);        
        require(state==StateValues.GAME_OVER);

    }

    function withdraw()
    hasMoney
    public
    {
        require(block.number>deadline);
    }
    
    
}