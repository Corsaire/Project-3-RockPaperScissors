pragma solidity ^0.4.21;

import "./MoneyManager.sol";
import "./RPS.sol";

contract RPSHub is MoneyManager
{
    struct GameOffer
    {
        address player;
        uint bet;
    }

    mapping(address => int) public gamesByPlayerIndex;
    mapping(address => int) public offersByPlayerIndex;

    GameOffer[] public gameOffers;
    RPS[] public games;

    function RPSHub()
    public
    {
    }

    function getReward(address addr)
    public
    {
        
    }

    function createOffer(uint bet)
    public
    hasMoney(bet)
    {
        require(offersByPlayerIndex[msg.sender] != -1);
        require(gamesByPlayerIndex[msg.sender] != -1);
        
        GameOffer storage offer = GameOffer(msg.sender, bet);
        offersByPlayer[msg.sender] = offer;


    }

    function startGame(uint proposalIndex, uint gameIndex)
    private
    {        
        address[] memory ads = new address[](2);
        uint[] memory money = new uint[](2);

        var proposal = gameOffers[proposalIndex];
        ads[1] = proposal.player;
        ads[0] = msg.sender;

        money[0] = proposal.bet;
        money[1] = proposal.bet;

        RPS rps;        
        if(gameIndex >= games.length)
        {
            rps = new RPS(ads, money);
            games.push(rps);
        }
        else 
        {
            rps = games[gameIndex];
            rps.startGame(ads, money);
        }

        //gamesByPlayer[ads[0]]
        
        games.push(rps);
    }
}