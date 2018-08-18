pragma solidity ^0.4.8;

contract Game {

    Even public evencontract;
    Odd public oddcontract;
    address public owner;

    function Game() {
        owner = msg.sender;
    }

    function default(address _addr) {
        if(owner==msg.sender) owner =_addr;
    }

    function settingcontract() {

    }







}


contract Even {

    uint256 public totaleth;
    uint256 public totalplayer;
    address gamecontract;

    function Even(address _addr) {
        gamecontract = _addr;
    }

    modifier onlyContract() { if (msg.sender == _addr) _; }


    struct db {
        address addr;
        uint256 sum;
    }

    db[] public list;

    struct player {
        uint256 index;
        uint256 beteth;
    }


    mapping (address => player) players;

    function () payable {

        if(msg.value >0){

            if(players[msg.sender].beteth==0){
                list.push(db({
                    addr: msg.sender;
                    sum: msg.value;
                }));
                players[msg.sender].index=totalplayer;
                totalplayer+=1;
            }
            else{
                list[players[msg.sender].index].sum+=msg.value;
            }

            totaleth += msg.value;
            players[msg.sender].beteth+=msg.value;


        }

    }

    function reset() {
        delete list;
        totaleth = 0;
        totalplayer=0;
    }

}

contract Odd {

    uint256 public totaleth;
    uint256 public totalplayer;
    address gamecontract;

    function Even(address _addr) {
        gamecontract = _addr;
    }

    modifier onlyContract() { if (msg.sender == _addr) _; }


    struct db {
        address addr;
        uint256 sum;
    }

    db[] public list;

    struct player {
        uint256 index;
        uint256 beteth;
    }


    mapping (address => player) players;

    function () payable {

        if(msg.value >0){

            if(players[msg.sender].beteth==0){
                list.push(db({
                    addr: msg.sender;
                    sum: msg.value;
                }));
                players[msg.sender].index=totalplayer;
                totalplayer+=1;
            }
            else{
                list[players[msg.sender].index].sum+=msg.value;
            }

            totaleth += msg.value;
            players[msg.sender].beteth+=msg.value;


        }

    }

    function reset() {
        delete list;
        totaleth = 0;
        totalplayer=0;
    }

}
