import React, { Component } from 'react'
import './ReceiveMoney.css'
import RemittanceContract from '../../../build/contracts/Remittance.json';
import Web3 from 'web3';


const provider = new Web3.providers.HttpProvider('http://localhost:8545')
const contract = require('truffle-contract')
const Remittance = contract(RemittanceContract)
Remittance.setProvider(provider);
var web3 = new Web3(provider);

class CreateContract extends Component {
  constructor(props) {
    super(props)

    this.receiveMoney = this.receiveMoney.bind(this)
  }


  receiveMoney(e)
  {
    e.preventDefault();
    var address = this.addressInput.value;
    if (!/^(0x)?[0-9a-f]{40}$/i.test(address)) {
      alert("Wrong address");
      return;
    }

   Remittance.at(address).then( instance => 
    {
      console.log(instance.address);
      return instance.receiveMoney(this.password1Input.value, this.password2Input.value, {from: web3.eth.accounts[1], gas: 1000000});
    }).then( response => {console.log(response); alert("Success")}
    ).catch((e)=> {console.log(e); alert(e);});
  }


  render() {
    return (
      <form className='CreateContract'>
        <label className='title'>Form for Carol</label>

        <label>Contract address</label>
        <input type='text' ref={(i)=>{ if(i) { this.addressInput = i}}} />
        
        <label htmlFor='password_1'>Password 1</label>
        <input id='password_1' type='text' ref={(i)=>{ if(i) { this.password1Input = i}}} />
       
        <label htmlFor='password_2'>Password 2</label>
        <input id='password_2'type='text' ref={(i) => { if(i) { this.password2Input = i}}} />
        
        <button onClick={this.receiveMoney}>Receive</button>
      </form>
    )
  }
}

export default CreateContract