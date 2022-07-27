# Instruction

1. The general workflow of token launchpad automatic refund system can be thought of as:

   - We need to deploy a contract which can read the data below:
   - Each wallet address who participated in that token’s crowdfunding at our launchpad
   - How much each corresponding wallet have bought in BUSD
   - How much each corresponding wallet got from at the first vesting, and how much is remaining to be vested to them
   - How is the vesting schedule (linear vs monthly)

2. Within 24 hours of cex/dex listing of a <!-- TODO: token? -> NFT : FT --> token, users then will have the frame/opportunity to ask for automatic refunds in their profile section’s refund section, selecting the project they want refund from, and clicking a button to interact with the smart contract if they want a refund.
3. Once they ask for a refund, we will require them to have not sold the token and bought it back. Either the tokens have to stay in the claim system, and/or it has to stay in their wallet without any trades being made besides from our claim system to the particular wallet.
4. When the refund is called, the contract will check whether the full 1st vesting is untouched, (if traded, or sent to another address then will give an error so user can’t continue), get those particular tokens from the user/or claim contract out, and deliver back the BUSD allocation that the user paid in the same contract call.
5. A) In the cases of monthly vestings, it needs to generate us the list of all the wallets who have completed refund, so our team can calculate the amounts, and do the rest of the legwork (such as calculating the rest of the vestings those users will supposed to get, and send all those tokens altogether back to the project, since they will be refunded)

   B) In the cases of linear vestings, we can do them, so we upload the first vesting claim only on the first day, not the whole linear vesting, so we can do the same method as above again. Only upload the next vestings of the people who haven’t called for a refund, after the 24 hours pass. So we don’t do anything extra there in technical aspects compared to A.
