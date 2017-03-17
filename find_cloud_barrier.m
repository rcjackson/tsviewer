function alts = find_cloud_barrier(date, start_time, end_time)

f = netcdf(['isdac.' date '.all.cdf']);

time = f{'time'}(:);
start_index = find(time == start_time);
end_index = find(time == end_time);
FSSP96_conc = f{'FSSP096_conc'}(start_index:end_index,:);
FSSP96_n = sum(FSSP96_conc, 2);
diffssp = [0; diff(FSSP96_n)];
alt = f{'PreAlt'}(:);

alt(diffssp > 50)
close(f);