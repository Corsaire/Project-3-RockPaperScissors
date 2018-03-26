pragma solidity ^0.4.21;

import "./MoneyManager.sol";
import "./RPS.sol";

contract RPSHub is MoneyManager
{
    struct GameProposal
    {
        address player;
        uint bet;
    }

    GameProposal[] gameProposals;
    RPS[] games;

    function RPSHub()
    public
    {
    }


    function getReward(address addr)
    public
    {
     //   var rps = RPS(addr);
       // uint[] memory rewards = rps.getReward();
       // for(uint i=0; i<rewards.length;i++)
       // {
        //    address adr = rps.playersArray(i).addr;
      //      balance[adr] += rewards[i];
       // }
    }

    function startGame(int proposalIndex, int gameIndex)
    private
    {
        RPS rps = new RPS();
        address[] memory ads = new address[](2);
        ads[0]=10;
        ads[1] = 100;
        
        uint[] memory m = new uint[](2);
        m[0]=1;
        m[1] = 2;

        rps.startGame(ads, m);
        games.push(rps);
    }
}