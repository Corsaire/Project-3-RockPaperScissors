pragma solidity ^0.4.6;
contract RPS
{
    struct Player
    {
        address addr;
        uint money;
        bytes32 decision;
        bytes32 decryptionKey;
    }

    mapping(address => Player) public players;
    uint public deadline;
    Player[] playersArray;
    uint decisionsCount;
    
    //0 - waiting for players decision
    //1 - waiting for salt
    //2 - game over
    //3 - game over and funds are withdrawed
    uint gameState;

    modifier hasMoney()
    {
        require(players[msg.sender].money>0);
        _;
    }
    
    function RPS(address[] addresses, uint[] money) 
    payable 
    public
    { 
        for(uint i = 0; i < addresses.length; i++)
        {
            Player memory p = Player({addr:addresses[i], money:money[i], decision:0, decryptionKey:0});
            playersArray.push(p);
        }
    }
    
    function submitDecision(bytes32 decision)
    hasMoney
    public 
    {
        require(block.number<=deadline);
        require(players[msg.sender].decision==0);
        players[msg.sender].decision = decision;
        decisionsCount++;
    }

    function GetPlayer(address addr) public returns(address) 
    {
        return players[addr].addr;
    }
    

    function getReward()
    hasMoney
    public
    {
        require(block.number>deadline);
    }

    

    function withdraw()
    hasMoney
    public
    {
        require(block.number>deadline);
    }
    
    
}