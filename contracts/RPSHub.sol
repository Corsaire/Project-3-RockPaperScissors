pragma solidity ^0.4.21;

import "./MoneyManager.sol";
import "./RPS.sol";

contract RPSHub is MoneyManager
{
    struct GameOffer
    {
        address player;
        uint bet;
        bool active;
    }

    mapping(address => uint) public gamesByPlayerIndex;
    mapping(address => uint) public offersByPlayerIndex;

    GameOffer[] public gameOffers;
    RPS[] public games;

    function RPSHub()
    public
    {
        gameOffers.push(GameOffer(0,0,false));
        games.push(RPS(0));
    }

    function getReward(address addr)
    public
    {
        
    }

    function createOffer(uint bet)
    public
    hasMoney(bet)
    {
        require(offersByPlayerIndex[msg.sender] == 0);
        require(gamesByPlayerIndex[msg.sender] == 0);
        
        GameOffer memory offer = GameOffer(msg.sender, bet,true);
        gameOffers.push(offer);
        offersByPlayerIndex[msg.sender] = gameOffers.length - 1;        
    }

    function startGame(uint offerIndex, uint gameIndex)
    private
    {                
        GameOffer memory offer = gameOffers[offerIndex];
        offer.active = false;
        RPS rps;        
        if(gameIndex >= games.length)
        {
            rps = new RPS([offer.player, msg.sender], [offer.bet, offer.bet]);
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