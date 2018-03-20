import React, { Component } from 'react'
import './CreateContract.css'

import RemittanceContract from '../../../build/contracts/Remittance.json';
import Web3 from 'web3';
var keccak = require('keccak');


const provider = new Web3.providers.HttpProvider('http://localhost:8545')
const contract = require('truffle-contract')
const Remittance = contract(RemittanceContract)
Remittance.setProvider(provider);
var web3 = new Web3(provider);

class CreateContract extends Component {
  constructor(props) {
    super(props)
    this.address="none";
    this.createcontract = this.createcontract.bind(this)
  }

  createcontract(e)
  {
    e.preventDefault()
    var deadline = this.deadlineInput.value;
    var hash ="0x"+ keccak('keccak256').update(this.password1Input.value).update(this.password2Input.value).digest('hex').toString('hex');
    
    Remittance.new(hash, deadline, {from: web3.eth.accounts[0], value:web3.toWei(this.amountInput.value), gas: 1005000}).then( instance => 
    {
      this.address = instance.address;
      this.setState({address : this.address});
      console.log(instance.address);
    }).catch(console.log);
  }

  render() {
    return (
      <form className='CreateContract'>
      
        <label className="title" >Form for Alice</label>
        <label htmlFor='password_1'>Password 1</label>
        <input id='password_1' className='Password' type='text' ref={(i)=>{ if(i) { this.password1Input = i}}} />
        <label htmlFor='password_2'>Password 2</label>
        <input id='password_2' className='Password' type='text' ref={(i) => { if(i) { this.password2Input = i}}} />
        <br/>
        <label htmlFor='amount'>Amount (in Eth)</label>
        <input id='amount' className='Amount' type='text' ref={(i) => { if(i) { this.amountInput = i}}} />
        <label htmlFor='deadline'>Deadline (block number)</label>
        <input id='deadline' className='Deadline' type='text' ref={(i) => { if(i) { this.deadlineInput = i}}} />
        <br/>

        <label>Address: {this.address} </label>
      
        <br/>

        <button className='CreateBnt' onClick={this.createcontract}>Create</button>
      </form>
    )
  }
}

export default CreateContract