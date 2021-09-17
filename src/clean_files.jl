"""
Takes a CSV file and makes it into a dataframe with reasonable header, etc.
"""
function importCSV(filename;header=3)
    #Read File as Dataframe
    df = CSV.read(filename,DataFrame,header=header)
    return df
end

"""
Cleans a MACCOR file based on everything wrong I see so far
"""
function clean_df(df)
    df = convertTestTime(df)
    df = convertStepTime(df)
    df = cleanGarbageCols(df)
end

"""
Converts a dataframe with raw time vector to usable date-time format
"""
function convertTestTime(df;start=DateTime(0,1,1,0,0))
    testTime = df.TestTime
    testTimes = split.(testTime)
    newTestTimes = Array{DateTime,1}(undef,length(testTime))
    for (i,time) in enumerate(testTimes)
        testday = time[1]
        #Since d is one letter, the day is 1:end-1
        numTestDays = testday[1:end-1]
        numTestDays = parse(Int,numTestDays)
        testtime = time[2]
        testtime = split(testtime,(':','.'))
        testtime = parse.(Int,testtime)
        testtime = start+Day(numTestDays)+Hour(testtime[1])+Minute(testtime[2])+Second(testtime[3])+Millisecond(testtime[4]*10)
        newTestTimes[i] = testtime
    end
    df.TestTime = newTestTimes
    return df
end


"""This converts the step times of the testing DF's to reasonable times"""
function convertStepTime(df;start=DateTime(0,1,1,0,0))
    stepTime = df.StepTime
    stepTimes = split.(stepTime)
    newStepTimes = Array{DateTime,1}(undef,length(stepTime))
    for (i,time) in enumerate(stepTimes)
        stepday = time[1]
        #Since d is one letter, the day is 1:end-1
        numStepDays = stepday[1:end-1]
        numStepDays = parse(Int,numStepDays)
        steptime = time[2]
        steptime = split(steptime,(':','.'))
        steptime = parse.(Int,steptime)
        steptime = start+Day(numStepDays)+Hour(steptime[1])+Minute(steptime[2])+Second(steptime[3])+Millisecond(steptime[4]*10)
        newStepTimes[i] = steptime
    end
    df.StepTime = newStepTimes
    return df
end

"""This gets rid of cols that are useless"""
function cleanGarbageCols(df)
    df = deepcopy(df) #Don't want to mutate here
    cols = names(df)
    for col in cols
        #My Current Best guess heuristic on what a garbage column looks like, LOL
        if any(ismissing.(df[:,col]))
            @warn "Deleted $col"
            select!(df,Not(col))
            continue
        end
        if all(df[:,col].==0)
            select!(df,Not(col))
        end  
    end
    return df
end
