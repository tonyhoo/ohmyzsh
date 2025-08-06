# Customized script used for work Amazon SWF
# Prerequiste is to have jq and aws cli installed

CHARGEBACK_DOMAIN="Chargeback.EU.prod"

# Get activity action result
# Usage:  getActivityActionResult <workflowId> <runId> <activityName>
# getActivityActionResult 82106282 22ry3VJTGdfGUmUQdNl5TIKv7KLBBx7q+cBDtvYxJ6zDo= InternalChargebackActivities.emailSeller
function getActivityActionResult() {
	getActivityActionDetails $* | jq ".activityTaskCompletedEventAttributes.result"
}

# Get activity action result
# Usage:  getActivityActionResult <workflowId> <runId> <activityName>
# getActivityActionDetails 82106282 22ry3VJTGdfGUmUQdNl5TIKv7KLBBx7q+cBDtvYxJ6zDo= InternalChargebackActivities.emailSeller
function getActivityActionDetails() {
	[ $# -ne 3 ] && echo "Wrong parameters passed to run workflow. Please pass in workflowId, runId and workflowAction" && return 1
	local workflowId=$1
	local runId=$2
	local workflowAction=$3
	local eventId=$(getWorkflowExecutionHistory $workflowId $runId |jq ".events[] | select(.activityTaskScheduledEventAttributes.activityType.name==\"$workflowAction\")|.eventId")
	getWorkflowExecutionHistory $workflowId $runId | jq ".events[] | select(.activityTaskCompletedEventAttributes.scheduledEventId==$eventId)"
}


# Get workflow execution history list
# Usage: getWorkflowExecutionHistory <workflowId> <runId>
# getWorkflowExecutionHistory 82106282 22ry3VJTGdfGUmUQdNl5TIKv7KLBBx7q+cBDtvYxJ6zDo=
function getWorkflowExecutionHistory() {
	[ $# -ne 2 ] && echo "Wrong parameter passed to run workflow. Please pass in workflowId and runId" && return 1
	local workflowId=$1
	local runId=$2
	local execution="workflowId=$workflowId,runId=$runId"
	aws swf get-workflow-execution-history --domain $CHARGEBACK_DOMAIN --execution $execution
}

# Search workflow execution lists by time range
# Usage: listWorkflowExecutions <workflowId> <startTimeStamp> <endTimeStamp>
# listWorkflowExecutions 82106282 1455344407 1454481733
function listWorkflowExecutions() {
	[ $# -ne 3 ] && echo "Wrong parameter passed to run workflow. Please pass in start timestamp, end timestamp and workflowId" && return 1
	local workflowId=$1
	local start=$2
	local end=$3
	local result=$(aws swf list-closed-workflow-executions --domain $CHARGEBACK_DOMAIN --start-time-filter "oldestDate=$start,latestDate=$end" --execution-filter "workflowId=$workflowId")
	echo $result
}
