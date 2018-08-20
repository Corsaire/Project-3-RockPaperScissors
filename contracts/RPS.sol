pragma solidity ^0.4.23;

import 'openzeppelin-solidity/contracts/ownership/Ownable.sol';

contract RPS is Ownable
{
    enum StateValues { WAITING_FOR_PLAYERS, WAITING_FOR_ENCRYPTED_DECISION, WAITING_FOR_SALT, GAME_OVER}
    enum DecisionValues { NONE, ROCK, PAPER, SCISSORS}

    struct Player
    {
        address addr;
        bytes32 encryptedDecision;
        bool active;
    }

    mapping(address => Player) public players;
    address[] public playersAddresses;
    
    uint constant DEADLINE_DEFAULT = 100;
    uint public deadline;    
    uint playersCount;
    
    address[][4] decisions;
    uint round;
    uint messagesReceived;
    uint uniqueDecisions;
    uint winningDecision;
    uint activePlayersCount;

    address winner;
    //0 - waiting for players decision
    //1 - waiting for salt
    //2 - game over
    //3 - game over and funds are withdrawed
    StateValues state = StateValues.GAME_OVER_ALL_WITHDRAWED;

    event LogDecisionSubmited(address player, bytes32 encryptedDecision);
    event LogDecisionDecrypted(address player, DecisionValues decision);
    event LogFundsWithdrawed(address[] addresses);
    event LogStateChanged(address sender, StateValues state);
    event LogGameStarted(address[] addresses);

    modifier onlyPlayer()
    {
        require(players[msg.sender].active);
        _;
    }

    modifier resultReady()
    {
        require(state == StateValues.GAME_OVER || (state != StateValues.GAME_OVER_ALL_WITHDRAWED && block.number > deadline));
        _;
    }
    
    function RPS(uint _playersCount) 
    public
    {     
        state = StateValues.GAME_OVER;
        startGame(_playersCount);   
    }

    function startGame(uint _playersCount)
    onlyOwner
    public
    {        
        require(_playersCount >= 2);
        require(state == StateValues.GAME_OVER);
        playersCount = _playersCount;
        activePlayersCount = _playersCount;
        setState(StateValues.WAITING_FOR_PLAYERS);
    }
    
    function joinGame(address player)
    onlyOwner
    public
    {
        require(player != 0);
        require(state == StateValues.WAITING_FOR_PLAYERS);
        require(block.number <= deadline);
        uint length = playersArray.push(Player(player,  0, DecisionValues.NONE, 0, 0, true));
        players[msg.sender] = playersArray[length - 1];

        if(length == playersCount)
        {
            setState(StateValues.WAITING_FOR_ENCRYPTED_DECISION);
        }
    }

    function setState(StateValues _state)
    private
    {
        messagesReceived = 0;               
        deadline = block.number + DEADLINE_DEFAULT;

       /* if(_state == StateValues.Decision)
        {
            nonZeroDecision = 0;
            winningDecision = 0;
            for(uint i = 1; i <= 3; i++)
                decisions[i] = 0;
        }*/

        state = _state;
        emit LogStateChanged(msg.sender, _state);
    }

    function submitEncryptedDecision(bytes32 encryptedDecision)
    onlyPlayer
    public 
    {
        require(state == StateValues.WAITING_FOR_DECISION);
        require(block.number <= deadline);
        require(encryptedDecision != 0);
        require(players[msg.sender].encryptedDecision == 0);
        players[msg.sender].encryptedDecision = encryptedDecision;
        
        messagesReceived++;
        emit LogDecisionSubmited(msg.sender, encryptedDecision);
        if(messagesReceived == activePlayersCount)
           setState(StateValues.SALT);
        
            
    }

    function submitSalt(bytes32 salt, DecisionValues decision)
    public 
    onlyPlayer
    {
        Player storage p = players[msg.sender];
        require(state==StateValues.WAITING_FOR_SALT);
        require(block.number<=deadline);
        require(salt!=0);        
        require(keccak256(decision, salt) == p.encryptedDecision);
        p.encryptedDecision = 0;
        p.decision = decision;

        messagesReceived++;
        emit LogDecisionDecrypted(msg.sender, p.decision);
        if(messagesReceived == 0)
            setState(StateValues.GAME_OVER);
    }    

    function processDecision(DecisionValues decision, address player)
    private
    returns(bool)
    {
        if(decisions[decision] == 0) 
        {
            uniqueDecisions++;
            if(nonZeroDecision==3)
            {                
                setState(StateValues.Decision);
                return false;
            }
        }
        decisions[decision]++;
        
        if(winningDecision==0)
            winningDecision = decision;
        else 
        {
            if(winningDecision > decision || (decision == 1 && winningDecision == 3))
                winningDecision = decision;
        }        


        messagesReceived--;
        emit LogDecisionDecrypted(msg.sender, p.decision);
        if(messagesReceived == 0)
        {
            if(decisions[winningDecision].length == 1)                
            {
                winner = decisions[winner][0];
                state = StateValues.GAME_OVER;
            }
            else 
            {
                for(int i = 0; i < playersArray.length; i++)
                {
                    if(!playersArray[i].deleted && playersArray.decision!=winningDecision)
                    {
                        activePlayersCount--;
                        playersArray[i].deleted = true;
                    }
                }
            }
        }

        return true;
    }
    
}