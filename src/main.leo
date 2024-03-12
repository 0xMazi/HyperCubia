// The 'hypercubia' program.
program hypercubia.aleo {
    
    // for local test
    mapping account: address => u64;

    record token {
        owner: address,
        amount: u64,
    }


    transition test2(public receiver: address, public amount: u32) -> (address, u32) {
        return (receiver, amount);
    }

    transition mint_public(public receiver: address, public amount: u64) {
        return then finalize(receiver, amount);
    }

    finalize mint_public(public receiver: address, public amount: u64) {
        let current_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, current_amount + amount);
    }

    transition mint_private(receiver: address, amount: u64) -> token {
        return token {
            owner: receiver,
            amount: amount,
        };
    }

    transition transfer_public(public receiver: address, public amount: u64) {
        return then finalize(self.caller, receiver, amount);
    }

    finalize transfer_public(public sender: address, public receiver: address, public amount: u64) {
        let sender_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, sender_amount - amount);
        let receiver_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, receiver_amount + amount);
    }

    transition transfer_private(sender: token, receiver: address, amount: u64) -> (token, token) {
        let difference: u64 = sender.amount - amount;

        let remaining: token = token {
            owner: sender.owner,
            amount: difference,
        };

        let transferred: token = token {
            owner: receiver,
            amount: amount,
        };

        return (remaining, transferred);
    }

    transition transfer_private_to_public(sender: token, public receiver: address, public amount: u64) -> token {
        let difference: u64 = sender.amount - amount;

        let remaining: token = token {
            owner: sender.owner,
            amount: difference,
        };

        return remaining then finalize(receiver, amount);
    }

    finalize transfer_private_to_public(public receiver: address, public amount: u64) {
        let current_amount: u64 = Mapping::get_or_use(account, receiver, 0u64);
        Mapping::set(account, receiver, current_amount + amount);
    }

    transition transfer_public_to_private(public receiver: address, public amount: u64) -> token {
        let transferred: token = token {
            owner: receiver,
            amount: amount,
        };

        return transferred then finalize(self.caller, amount);
    }

    finalize transfer_public_to_private(public sender: address, public amount: u64) {
        let current_amount: u64 = Mapping::get_or_use(account, sender, 0u64);
        Mapping::set(account, sender, current_amount - amount);
    }

    //#####################################TESTING##################################################

    transition sum_with_loop () -> u64 {
        let sum: u64 = 0u64;
        let a: [u64; 4] = [1u64, 2u64, 3u64, 4u64];
        for i: u8 in 0u8..4u8 {
            sum += a[i];
        }
        return sum;
    }

    transition sum_with_loop_input (a: [u64; 4]) -> u64 {
        let sum: u64 = 0u64;
        for i: u8 in 0u8..4u8 {
            sum += a[i];
        }
        return sum;
    }

}

