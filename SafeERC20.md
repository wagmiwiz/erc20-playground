ERC20 is a standard and not all implementations follow strictly follow it.

For example, when it comes to transfers, some contracts:

- Don't reaturn true upon successful transfer
- Return false even on success
- Some don't return anything on success

Using wrappers such as SafeERC20 helps you perform transfers in safer ways when your use case supports arbitrary ERC20s (revert on all detectable failures etc)
