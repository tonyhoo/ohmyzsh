# Customized script used for oncall work

function getSealsResponseByTransactionId() {
    region="fe"
    case "$2" in 
		na)
			;;
		fe)
			region="fe"
			;;
        eu)
			region="eu"
			;;
		*)
			echo "Usage getSealsResponseByTransactionId <transactionId> <na|fe|eu>"
			;;
	esac
    kcurl -s "https://sealsclub-$region.amazon.com/paymentPlan.html?action=findBySealsIdentifierAction&identifierType=PAYMENT_PLAN_OPERATION_ID&identifier=$1&visibility=SPARSE&viewMode=OBJECT&maxResults=20&pagination=20"
}

function getDeclineCode() {
    region="fe"
    case "$2" in 
		"na")
			;;
		"fe")
			region="fe"
			;;
        "eu")
			region="eu"
			;;
		*)
			echo "Usage getDeclineCode <transactionId> <na|fe|eu>"
			;;
	esac
    getSealsResponseByTransactionId "$1" "$region"|grep -A10 "Detailed Result"   | grep "(" | cut -d"(" -f1 | xargs
}