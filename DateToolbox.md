# Convert Timestamp To Date and Time in JavaScript
Unlike other languages, JavaScript doesn't have equivalent for function strftime. Javascript however provides multiple functions to present date and time in human readable form. They are:

## Table
* toDateString - Converts the date portion of a Date object into a readable string
* toGMTString - Deprecated. Use the toUTCString() method instead
* toJSON - Returns the date as a string, formatted as a JSON date
* toLocaleDateString - Returns the date portion of a Date object as a string, using locale conventions
* toLocaleTimeString - Returns the time portion of a Date object as a string, using locale conventions
* toLocaleString - Converts a Date object to a string, using locale conventions
* toString - Converts a Date object to a string
* toTimeString - Converts the time portion of a Date object to a string
* toUTCString()- Converts a Date object to a string, according to universal time



## toDateString
Converts the date portion of a Date object into a readable string
```
var ts = new Date();
console.log(ts.toDateString());
# Mon Mar 9 2020
```
## toGMTString Deprecated. Use the toUTCString() method instead

## toISOString 
Returns the date as a string, using the ISO standard

```
var ts = new Date();
console.log(ts.toISOString());
# %2020-03-09T11:12:28+01:00
```
* toJSON - Returns the date as a string, formatted as a JSON date
* toLocaleDateString - Returns the date portion of a Date object as a string, using locale conventions
* toLocaleTimeString - Returns the time portion of a Date object as a string, using locale conventions
* toLocaleString - Converts a Date object to a string, using locale conventions
* toString - Converts a Date object to a string
* toTimeString - Converts the time portion of a Date object to a string
* toUTCString()- Converts a Date object to a string, according to universal time
