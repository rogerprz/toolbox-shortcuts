export function todaysDate(): string {
  const date = new Date();
  const dayOfWeek: string = dayOfTheWeekShort();
  const month: string = writtenShortMonth();
  const day: number = date.getDate();
  const year: number = date.getFullYear();

  const fullDate: string = `${dayOfWeek} ${month} ${day}, ${year}`;
  return fullDate;
}

export function currentTime(): string {
  const date = new Date();
  const hours = amPmTime();
  const mins = date.getMinutes();
  const time = `${hours[0]}:${mins} ${hours[1]}`;
  return time;
}

export function currentDate(): string {
  const d = new Date();
  let month = addZero(d.getMonth() + 1);
  let day = addZero(d.getDate());
  let currDate = `**** ${d.getFullYear()}-${month}-${day}`;
  return currDate;
}

function addZero(num: number) {
  if (num.toString().length < 2)
    // Integer of less than two digits
    return "0" + num; // Prepend a zero!
  return num.toString(); // return string for consistency
}

function amPmTime(): any {
  const date = new Date();
  const hours = date.getHours() > 11 ? date.getHours() - 12 : date.getHours();
  const amPm: string = date.getHours() > 11 ? "PM" : "AM";

  return [hours, amPm];
}

function writtenFullMonth() {
  const date = new Date();
  let month = [];
  month[0] = "January";
  month[1] = "February";
  month[2] = "March";
  month[3] = "April";
  month[4] = "May";
  month[5] = "June";
  month[6] = "July";
  month[7] = "August";
  month[8] = "September";
  month[9] = "October";
  month[10] = "November";
  month[11] = "December";
  return month[date.getMonth()];
}

function writtenShortMonth(): string {
  const date = new Date();
  let month = [];
  month[0] = "Jan";
  month[1] = "Feb";
  month[2] = "Mar";
  month[3] = "April";
  month[4] = "May";
  month[5] = "Jun";
  month[6] = "July";
  month[7] = "Aug";
  month[8] = "Sept";
  month[9] = "Oct";
  month[10] = "Nov";
  month[11] = "Dec";
  return month[date.getMonth()];
}

function dayOfTheWeekShort(): string {
  const date = new Date();
  let day = [];
  day[0] = "Sun";
  day[1] = "Mon";
  day[2] = "Tue";
  day[3] = "Wed";
  day[4] = "Thurs";
  day[5] = "Fri";
  day[6] = "Sat";
  return day[date.getDay()];
}
