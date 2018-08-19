pragma solidity ^0.4.8;

contract Game {

    Even public evencontract;
    Odd public oddcontract;
    address public evenaddr;
    address public oddaddr;
    address public thiscontract;
    uint256 public period;
    address feeaddr;
    uint public nextblocknumber;
    bool public gameon;

    modifier onlythisContract() { if (msg.sender == thiscontract) _; }
    modifier onlyContracts() { if (msg.sender == evenaddr || msg.sender == oddaddr) _; }

    function () payable {}

    function feed() {
        if(msg.sender != feeaddr) throw;
        evenaddr.call.value(0.1 ether)();
        oddaddr.call.value(0.1 ether)();
    }


    function Game() {
        thiscontract = msg.sender;
        feeaddr = msg.sender;
    }

    function set(address _addr1, address _addr2, uint256 _period) onlythisContract {
        evenaddr = _addr1;
        oddaddr = _addr2;
        evencontract = Even(_addr1);
        oddcontract = Odd(_addr2);
        evencontract.set(_addr2);
        oddcontract.set(_addr1);
        period = _period;
        thiscontract = this;
    }

    function start() onlyContracts {
        if(gameon == true) throw;
        if(evencontract.gettotaleth() > 0 && oddcontract.gettotaleth() > 0){
        nextblocknumber = block.number+1;
        gameon = true;
        }
    }

    function check(){
        if(gameon == false) throw;
        if(nextblocknumber < block.number)
        {
            bytes32 _blockhash = block.blockhash(nextblocknumber);
            if(_blockhash == 0) throw;
            if(uint(_blockhash)%2 ==0)
            {
                evencontract.win();
                oddcontract.lose();
            }
            else
            {
                oddcontract.win();
                evencontract.lose();
            }
            gameon == false;
        }
    }

    function withdraw() {
        if(msg.sender != feeaddr) throw;
        feeaddr.call.value(this.balance)();

    }

}


contract Odd {

    uint256 public totaleth;
    uint256 public totalplayer;
    address public gameaddr;
    address public oppaddr;
    address public thisaddr=this;
    Game public gamecontract;
    Even public oppcontract;

    function Odd(address _addr) {
        gameaddr=_addr;
        gamecontract=Game(gameaddr);
    }

    function gettotaleth() constant returns (uint256){
        return totaleth;
    }
    function getlength() constant returns (uint256){
        return list.length;
    }
    function getlist(uint256 _i) constant returns (address _addr, uint256 _sum){
        return (list[_i].addr,list[_i].sum);
    }

    function getplayer(address _addr) constant returns (uint256 _index, uint256 _beteth, bool _withdrawed){
        return (players[_addr].index, players[_addr].beteth, players[_addr].withdrawed);
    }

    function setwithdrawal(address _addr){
        players[_addr].withdrawed = false;
    }

    modifier onlyContracts() { if (msg.sender == thisaddr || msg.sender == oppaddr) _; }
    modifier onlyGameContract() { if (msg.sender == gameaddr) _; }

    function set(address _addr) onlyGameContract {
        oppaddr = _addr;
        oppcontract = Even(oppaddr);
    }

    struct Db {
        address addr;
        uint256 sum;
    }

    Db[] public list;

    struct player {
        uint256 index;
        uint256 beteth;
        bool withdrawed;
    }


    mapping (address => player) players;

    function () payable {
        if(msg.sender != gameaddr)
        {
        if(msg.value >0){

            if(players[msg.sender].beteth==0){
                list.push(Db({
                    addr: msg.sender,
                    sum: msg.value
                }));
                players[msg.sender].index=totalplayer;
                totalplayer+=1;
            }
            else{
                list[players[msg.sender].index].sum+=msg.value;
            }

            totaleth += msg.value;
            players[msg.sender].beteth+=msg.value;
            gamecontract.start();


        }
        }

    }

    function reset() onlyContracts {
        delete list;
        totaleth = 0;
        totalplayer=0;
    }

    function win() onlyGameContract {
        for(uint i=0; i<list.length; i++)
        {
            if(list[i].sum>0 && list[i].sum == players[list[i].addr].beteth) {
                    if(players[list[i].addr].withdrawed == true) throw;
                    list[i].addr.call.value(list[i].sum)();
                    players[list[i].addr].withdrawed = true;
            }
        }
    }

    function lose() onlyGameContract {
        uint256 fee = totaleth / 100;
        gameaddr.call.value(fee)();
        totaleth -= fee;
        for(uint i=0; i<oppcontract.getlength(); i++)
        {
            (address _addr, uint256 _sum) = oppcontract.getlist(i);
            (uint256 _index, uint256 _beteth, bool _withdrawed) = oppcontract.getplayer(_addr);
            if(_sum>0 && _sum == _beteth ) {
                    if(_withdrawed == true) throw;
                    uint256 reward = totaleth * ( _sum / oppcontract.gettotaleth() ) ;
                    _addr.call.value(reward)();
                    oppcontract.setwithdrawal(_addr);
            }
        }
        reset();
        oppcontract.reset();

    }

}


contract Even {

    uint256 public totaleth;
    uint256 public totalplayer;
    address public gameaddr;
    address public oppaddr;
    address public thisaddr=this;
    Game public gamecontract;
    Odd public oppcontract;

    function Even(address _addr) {
        gameaddr=_addr;
        gamecontract=Game(gameaddr);
    }

    function gettotaleth() constant returns (uint256){
        return totaleth;
    }
    function getlength() constant returns (uint256){
        return list.length;
    }
    function getlist(uint256 _i) constant returns (address _addr, uint256 _sum){
        return (list[_i].addr,list[_i].sum);
    }

    function getplayer(address _addr) constant returns (uint256 _index, uint256 _beteth, bool _withdrawed){
        return (players[_addr].index, players[_addr].beteth, players[_addr].withdrawed);
    }

    function setwithdrawal(address _addr){
        players[_addr].withdrawed = false;
    }

    modifier onlyContracts() { if (msg.sender == thisaddr || msg.sender == oppaddr) _; }
    modifier onlyGameContract() { if (msg.sender == gameaddr) _; }

    function set(address _addr) onlyGameContract {
        oppaddr = _addr;
        oppcontract = Odd(oppaddr);
    }

    struct Db {
        address addr;
        uint256 sum;
    }

    Db[] public list;

    struct player {
        uint256 index;
        uint256 beteth;
        bool withdrawed;
    }


    mapping (address => player) players;

    function () payable {
        if(msg.sender != gameaddr)
        {
        if(msg.value >0){

            if(players[msg.sender].beteth==0){
                list.push(Db({
                    addr: msg.sender,
                    sum: msg.value
                }));
                players[msg.sender].index=totalplayer;
                totalplayer+=1;
            }
            else{
                list[players[msg.sender].index].sum+=msg.value;
            }

            totaleth += msg.value;
            players[msg.sender].beteth+=msg.value;
            gamecontract.start();


        }
        }

    }

    function reset() onlyContracts {
        delete list;
        totaleth = 0;
        totalplayer=0;
    }

    function win() onlyGameContract {
        for(uint i=0; i<list.length; i++)
        {
            if(list[i].sum>0 && list[i].sum == players[list[i].addr].beteth) {
                    if(players[list[i].addr].withdrawed == true) throw;
                    list[i].addr.call.value(list[i].sum)();
                    players[list[i].addr].withdrawed = true;
            }
        }
    }

    function lose() onlyGameContract {
        uint256 fee = totaleth / 100;
        gameaddr.call.value(fee)();
        totaleth -= fee;
        for(uint i=0; i<oppcontract.getlength(); i++)
        {
            (address _addr, uint256 _sum) = oppcontract.getlist(i);
            (uint256 _index, uint256 _beteth, bool _withdrawed) = oppcontract.getplayer(_addr);
            if(_sum>0 && _sum == _beteth ) {
                    if(_withdrawed == true) throw;
                    uint256 reward = totaleth * ( _sum / oppcontract.gettotaleth() ) ;
                    _addr.call.value(reward)();
                    oppcontract.setwithdrawal(_addr);
            }
        }
        reset();
        oppcontract.reset();

    }

}
