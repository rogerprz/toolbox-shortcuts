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
## Other Functions

```
var ts = new Date();
console.log(ts.toDateString());
# Wed Mar 11 2020

console.log(ts.toGMTString());
# Thu, 12 Mar 2020 05:12:49 GMT

console.log(ts.toISOString());
# 2020-03-12T05:12:49.307Z

console.log(ts.toJSON());
# 2020-03-12T05:12:49.307Z

console.log(ts.toLocaleDateString());
# 3/11/2020

console.log(ts.toLocaleTimeString());
# 10:12:49 PM

console.log(ts.toLocaleString());
# 3/11/2020, 10:12:49 PM

console.log(ts.toString());
# Wed Mar 11 2020 22:12:49 GMT-0700 (Pacific Daylight Time)

console.log(ts.toTimeString());
# 22:12:49 GMT-0700 (Pacific Daylight Time)

console.log(ts.toUTCString());
# Thu, 12 Mar 2020 05:12:49 GMT
```

[Resource found here](https://timestamp.online/article/how-to-convert-timestamp-to-datetime-in-javascript)
