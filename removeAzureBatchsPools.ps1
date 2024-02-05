param (
  
    [Parameter(Mandatory=$true)] 
    [String] $accountName,
    [Parameter(Mandatory=$true)]
    [String] $Subscription
)
# Subscription
$SubscriptionId = Get-AutomationVariable -Name $Subscription

# Connect to Azure with system-assigned managed identity
Connect-AzAccount -Identity

# Ensures you do not inherit an AzContext in your runbook
Disable-AzContextAutosave -Scope Process

# set context
Set-AzContext –SubscriptionId $SubscriptionId

# Account and Context Vars
$context = Get-AzBatchAccount -AccountName $accountName

# Get all the Batch pools
$pools = Get-AzBatchPool -BatchContext $context

# Iterate through each pool
foreach ($pool in $pools) {
    # Check if the pool is currently enabled
    if ($pool.State -eq "Active") {
        # Stop the pool
        Remove-AzBatchPool -Id $pool.id -Force -BatchContext $context
        Write-Host "Removed pool: $($pool.id)"
    }
}
