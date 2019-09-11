function runQuickRF()

tic
fprintf('Running gpi_rfquickmap_v...\n');
gpi_rfquickmap_v
t(1) = toc;
t
fprintf('Running gpi_rfquickmap_h...\n');
gpi_rfquickmap_h
t(2) = toc;
fprintf('Total duration: %2.2f s\n', t(2));