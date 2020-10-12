# frozen_string_literal: true

task :split_cells, [:capacity] => :environment do |_, args|
  loop do
    if SplitCellEvent.pending.exists?
      SplitCellService.new.check_transactions
    else
      if args[:capacity].present?
        SplitCellService.new.call(args[:capacity].to_i)
      else
        SplitCellService.new.call
      end

    end
    UpdateOfficialAccountBalanceService.new.call
    official_account = Account.last
    balance = official_account.balance
    output_balance = Output.live.sum(:capacity).to_i
    if (output_balance - balance).abs <= 1000 * 10**8
      SplitCellService.new.check_transactions
      puts "Split completed"

      break
    end
  rescue RuntimeError
    puts "sleeping...."
    sleep(10)
  end
end
