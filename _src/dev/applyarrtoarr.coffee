anotherarr = ["lubb", "gluck", "puck"]
myarr = ["blubb"]

console.log "myarr"
console.dir myarr
console.log "+ anotherarr.slice(1):"
console.dir anotherarr[1...]
console.log "="

Array.prototype.push.apply(myarr, anotherarr[1...])
data = [myarr.join(':')]

console.dir myarr
