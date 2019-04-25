function [luminance, perf, ntrials, nleft] = get_perf_from_arr(con_perf, target_con)

luminance = [con_perf(:,1)'-target_con target_con-con_perf(:,1)'];
[luminance, sort_idx] = sort(luminance);
perf = [1-con_perf(:,3)' con_perf(:,2)'];
perf = perf(sort_idx);

ntrials = [con_perf(:,7)' con_perf(:,5)'];
ntrials = ntrials(sort_idx);

nleft = [con_perf(:,7)' - con_perf(:,6)' con_perf(:,4)'];
nleft = nleft(sort_idx);