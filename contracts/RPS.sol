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

    uint moneyPool;
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

    event LogDecisionSubmited(address player, bytes32 encryptedDecision);
    event LogDecisionDecrypted(address player, DecisionValues decision);
    event LogFundsWithdrawed(address[] addresses, uint[] money);
    event LogStateChanged(address sender, StateValues state);
    event LogGameStarted(address[] addresses, uint moneyPool);

    modifier onlyPlayer()
    {
        require(players[msg.sender].addr != 0);
        _;
    }

    modifier resultReady()
    {
        require(state == StateValues.GAME_OVER || (state != StateValues.GAME_OVER_ALL_WITHDRAWED && block.number > deadline));
        _;
    }
    
    function RPS() 
    public
    {        
    }

    function startGame(address[] addresses, uint[] money)
    onlyOwner
    public
    {
        require(addresses.length == 2);
        require(addresses.length == money.length);
        require(state == StateValues.GAME_OVER_ALL_WITHDRAWED);
        moneyPool = 0;
        for(uint i = 0; i < addresses.length; i++)
        {
            require(addresses[i] != 0);
            playersArray.push(Player({addr:addresses[i], money:money[i], encryptedDecision: 0, decision:DecisionValues.NONE, salt:0}));
            players[msg.sender] = playersArray[playersArray.length-1];
            moneyPool += money[i];
        }
        state = StateValues.DECISION;
        decisionsLeft = playersArray.length;
        deadline = block.number + DEADLINE_DEFAULT;
        emit LogGameStarted(addresses, moneyPool);
    }

    function setState(StateValues _state)
    private
    {
            decisionsLeft = playersArray.length;
            deadline = block.number + DEADLINE_DEFAULT;
            state = _state;
            emit LogStateChanged(msg.sender, _state);
    }

    function submitDecision(bytes32 encryptedDecision)
    onlyPlayer
    public 
    {
        require(state == StateValues.DECISION);
        require(block.number <= deadline);
        require(encryptedDecision != 0);
        require(players[msg.sender].encryptedDecision == 0);
        players[msg.sender].encryptedDecision = encryptedDecision;
        
        decisionsLeft--;
        emit LogDecisionSubmited(msg.sender, encryptedDecision);
        if(decisionsLeft == 0)
           setState(StateValues.SALT);
            
    }


    function submitSalt(bytes32 salt, DecisionValues decision)
    public 
    onlyPlayer
    {
        Player storage p = players[msg.sender];
        require(state==StateValues.SALT);
        require(block.number<=deadline);
        require(p.salt==0);        
        require(keccak256(p.decision, p.salt) == p.encryptedDecision);
        p.salt = salt;
        p.decision = decision;

        decisionsLeft--;
        emit LogDecisionDecrypted(msg.sender, p.decision);
        if(decisionsLeft == 0)
         setState(StateValues.GAME_OVER);
    }    

    function GetReward()
    onlyOwner
    resultReady
    public
    returns(uint[] memory money)
    {
        require(state == StateValues.GAME_OVER || (state != StateValues.GAME_OVER_ALL_WITHDRAWED && block.number > deadline));

        money = new uint[](playersArray.length);
        int winner = determineWinner();
        if(winner == -1)
        {
            money[0] = moneyPool / 2;            
            money[1] = moneyPool - moneyPool / 2;
            return;
        }
        else 
            money[uint(winner)] = moneyPool;
        
        moneyPool = 0;
        state = StateValues.GAME_OVER_ALL_WITHDRAWED;
    }

    function determineWinner() 
    view
    public
    resultReady
    returns(int)
    {        
        DecisionValues decision0 = players[0].decision;      
        DecisionValues decision1 = players[1].decision;  

        if(decision0 == decision1)
            return -1;     

        if(decision0==DecisionValues.ROCK && decision1==DecisionValues.PAPER) return 1;
        if(decision0==DecisionValues.PAPER && decision1==DecisionValues.ROCK) return 0;
        
        if(decision0==DecisionValues.ROCK && decision1==DecisionValues.SCISSORS) return 0;
        if(decision0==DecisionValues.SCISSORS && decision1==DecisionValues.ROCK) return 1;
        
        if(decision0==DecisionValues.PAPER && decision1==DecisionValues.SCISSORS) return 1;
        if(decision0==DecisionValues.SCISSORS && decision1==DecisionValues.PAPER) return 0;

        if(decision0 == DecisionValues.NONE && decision1!=DecisionValues.NONE)return 1;
        if(decision0 != DecisionValues.NONE && decision1==DecisionValues.NONE)return 0;

        return -1;
    }

    
    
}