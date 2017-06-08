// Determines if all required fields have been filled in a SharePoint list form
// - Easily scaleable method for testing any number of fields
// - Calculates total of amounts at end
// - Must run when user attempts to save new form to SharePoint List

window.saveButton = function(){
    // Lists to hold all name and amount values, pulled direct
    // from their respective fields with jquery.
    var nameList = [];
    var amountList = [];
    var i = 1; //counter
    var reName; //reuseable name holder
    var reValue; //reuseable value holder


    // Assign values to nameList.
    nameList[0] = reValue;
    do {
        i++;
        reName = 'Name' + i;
        reValue = $("input[title=" + reName + "]").val();
        i = i - 1;
        nameList[i] = reValue;
        i++;
    }
    while (i<=23);

    // Assign values to amountList.
    i = 1; //Reset counter
    // Remove any dollar signs & commas user may have used
    reValue = reValue.replace("$", "");
    reValue = reValue.replace(",", "");
    reValue = reValue * 1;
    amountList[0] = reValue;
    do {
        i++;
        reName = 'Amount' + i;
        reValue = $("input[title=" + reName + "]").val();
        reValue = reValue.replace("$", "");
        reValue = reValue.replace(",", "");
        reValue = reValue * 1;
        i = i - 1;
        amountList[i] = reValue;
        i++;
    }
    while (i<=23);

    // List to contain amounts that must be filled
    var mstFillList = [];

    // Create list of items that must be checked to ensure they are filled
    for (i = 0; i <= 24;) {
        if(nameList[i] !== ''){
            if(amountList[i] === 0) {
                mstFillList[i] = 1;
            } else {
                mstFillList[i] = 0;
            }
        } else {
            mstFillList[i] = 0;
        }
        i++;
    }

    // Extract non-filled items from mstFillList
    var proceedYN = 'yes';
    reName = 'Error: Amount boxes for the following Payees are empty and must be filled: ';
    for (i = 0; i <= 5;){
        if(mstFillList[i] == 1){
            reName = reName + nameList[i];
            reName = reName + ', ';
            proceedYN = 'no';
        }
        i++;
    }
    // Fix alert string by removing extra comma/space at end
    i = reName.length;
    i = i - 2;
    reName = reName.slice(0, i);
    reName = reName + '.';

    // Calculate total
    var totalAmount = amountList[0] + amountList[1] + amountList[2] + amountList[3] + amountList[4];
    totalAmount = totalAmount.toFixed(2);
    totalAmount = "$" + totalAmount;
    var totalBox = $("input[title='Grand Total Required Field']").val();

    // Only proceed with calculate if no items were left unfilled that should be filled
    if(proceedYN == 'no'){
        alert(reName);
        return false;
    } else {
        totalBox = $("input[title='Grand Total Required Field']").val(totalAmount);
        return true;
    }
}
