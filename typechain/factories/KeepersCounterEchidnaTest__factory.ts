/* Autogenerated file. Do not edit manually. */
/* tslint:disable */
/* eslint-disable */
import { Signer, utils, Contract, ContractFactory, Overrides } from "ethers";
import { Provider, TransactionRequest } from "@ethersproject/providers";
import type {
  KeepersCounterEchidnaTest,
  KeepersCounterEchidnaTestInterface,
} from "../KeepersCounterEchidnaTest";

const _abi = [
  {
    inputs: [],
    stateMutability: "nonpayable",
    type: "constructor",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "",
        type: "bytes",
      },
    ],
    name: "checkUpkeep",
    outputs: [
      {
        internalType: "bool",
        name: "upkeepNeeded",
        type: "bool",
      },
      {
        internalType: "bytes",
        name: "",
        type: "bytes",
      },
    ],
    stateMutability: "nonpayable",
    type: "function",
  },
  {
    inputs: [],
    name: "counter",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "echidna_test_perform_upkeep_gate",
    outputs: [
      {
        internalType: "bool",
        name: "",
        type: "bool",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "interval",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [],
    name: "lastTimeStamp",
    outputs: [
      {
        internalType: "uint256",
        name: "",
        type: "uint256",
      },
    ],
    stateMutability: "view",
    type: "function",
  },
  {
    inputs: [
      {
        internalType: "bytes",
        name: "",
        type: "bytes",
      },
    ],
    name: "performUpkeep",
    outputs: [],
    stateMutability: "nonpayable",
    type: "function",
  },
];

const _bytecode =
  "0x60a060405234801561001057600080fd5b50620a8c0080608081815250504260018190555060008081905550506080516106ff61004e600039600081816101bc01526101ff01526106ff6000f3fe608060405234801561001057600080fd5b50600436106100625760003560e01c80633f3b3b27146100675780634585e33b1461008557806361bc221a146100a15780636e04ff0d146100bf5780637d1b7ebd146100f0578063947a36fb1461010e575b600080fd5b61006f61012c565b60405161007c919061023a565b60405180910390f35b61009f600480360381019061009a91906102ce565b610132565b005b6100a96101b0565b6040516100b6919061023a565b60405180910390f35b6100d960048036038101906100d4919061045c565b6101b6565b6040516100e7929190610548565b60405180910390f35b6100f86101f1565b6040516101059190610578565b60405180910390f35b6101166101fd565b604051610123919061023a565b60405180910390f35b60015481565b600061014c604051806020016040528060008152506101b6565b5090508061018f576040517f08c379a0000000000000000000000000000000000000000000000000000000008152600401610186906105f0565b60405180910390fd5b4260018190555060016000546101a5919061063f565b600081905550505050565b60005481565b600060607f0000000000000000000000000000000000000000000000000000000000000000600154426101e99190610695565b119150915091565b60008060005414905090565b7f000000000000000000000000000000000000000000000000000000000000000081565b6000819050919050565b61023481610221565b82525050565b600060208201905061024f600083018461022b565b92915050565b6000604051905090565b600080fd5b600080fd5b600080fd5b600080fd5b600080fd5b60008083601f84011261028e5761028d610269565b5b8235905067ffffffffffffffff8111156102ab576102aa61026e565b5b6020830191508360018202830111156102c7576102c6610273565b5b9250929050565b600080602083850312156102e5576102e461025f565b5b600083013567ffffffffffffffff81111561030357610302610264565b5b61030f85828601610278565b92509250509250929050565b600080fd5b6000601f19601f8301169050919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052604160045260246000fd5b61036982610320565b810181811067ffffffffffffffff8211171561038857610387610331565b5b80604052505050565b600061039b610255565b90506103a78282610360565b919050565b600067ffffffffffffffff8211156103c7576103c6610331565b5b6103d082610320565b9050602081019050919050565b82818337600083830152505050565b60006103ff6103fa846103ac565b610391565b90508281526020810184848401111561041b5761041a61031b565b5b6104268482856103dd565b509392505050565b600082601f83011261044357610442610269565b5b81356104538482602086016103ec565b91505092915050565b6000602082840312156104725761047161025f565b5b600082013567ffffffffffffffff8111156104905761048f610264565b5b61049c8482850161042e565b91505092915050565b60008115159050919050565b6104ba816104a5565b82525050565b600081519050919050565b600082825260208201905092915050565b60005b838110156104fa5780820151818401526020810190506104df565b83811115610509576000848401525b50505050565b600061051a826104c0565b61052481856104cb565b93506105348185602086016104dc565b61053d81610320565b840191505092915050565b600060408201905061055d60008301856104b1565b818103602083015261056f818461050f565b90509392505050565b600060208201905061058d60008301846104b1565b92915050565b600082825260208201905092915050565b7f54696d6520696e74657276616c206e6f74206d65740000000000000000000000600082015250565b60006105da601583610593565b91506105e5826105a4565b602082019050919050565b60006020820190508181036000830152610609816105cd565b9050919050565b7f4e487b7100000000000000000000000000000000000000000000000000000000600052601160045260246000fd5b600061064a82610221565b915061065583610221565b9250827fffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff0382111561068a57610689610610565b5b828201905092915050565b60006106a082610221565b91506106ab83610221565b9250828210156106be576106bd610610565b5b82820390509291505056fea2646970667358221220a5bb55902d8a435348f5121ff0b8284478dc78b2a5b3489f971bead6c242b5a364736f6c634300080a0033";

type KeepersCounterEchidnaTestConstructorParams =
  | [signer?: Signer]
  | ConstructorParameters<typeof ContractFactory>;

const isSuperArgs = (
  xs: KeepersCounterEchidnaTestConstructorParams
): xs is ConstructorParameters<typeof ContractFactory> => xs.length > 1;

export class KeepersCounterEchidnaTest__factory extends ContractFactory {
  constructor(...args: KeepersCounterEchidnaTestConstructorParams) {
    if (isSuperArgs(args)) {
      super(...args);
    } else {
      super(_abi, _bytecode, args[0]);
    }
    this.contractName = "KeepersCounterEchidnaTest";
  }

  deploy(
    overrides?: Overrides & { from?: string | Promise<string> }
  ): Promise<KeepersCounterEchidnaTest> {
    return super.deploy(overrides || {}) as Promise<KeepersCounterEchidnaTest>;
  }
  getDeployTransaction(
    overrides?: Overrides & { from?: string | Promise<string> }
  ): TransactionRequest {
    return super.getDeployTransaction(overrides || {});
  }
  attach(address: string): KeepersCounterEchidnaTest {
    return super.attach(address) as KeepersCounterEchidnaTest;
  }
  connect(signer: Signer): KeepersCounterEchidnaTest__factory {
    return super.connect(signer) as KeepersCounterEchidnaTest__factory;
  }
  static readonly contractName: "KeepersCounterEchidnaTest";
  public readonly contractName: "KeepersCounterEchidnaTest";
  static readonly bytecode = _bytecode;
  static readonly abi = _abi;
  static createInterface(): KeepersCounterEchidnaTestInterface {
    return new utils.Interface(_abi) as KeepersCounterEchidnaTestInterface;
  }
  static connect(
    address: string,
    signerOrProvider: Signer | Provider
  ): KeepersCounterEchidnaTest {
    return new Contract(
      address,
      _abi,
      signerOrProvider
    ) as KeepersCounterEchidnaTest;
  }
}