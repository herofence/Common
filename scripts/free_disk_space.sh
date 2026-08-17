
echo "=============================================================================="
echo "Freeing up disk space on CI system"
echo "=============================================================================="

echo "清单100个最大的包"
dpkg-query -Wf '${Installed-Size}\t${Package}\n' | sort -n | tail -n 100
df -h
echo "移除大的包裹"
sudo apt-get -y purge firefox
sudo apt-get remove -y '^dotnet-.*'
sudo apt-get remove -y '^llvm-.*'
sudo apt-get remove -y 'php.*'
sudo apt-get remove -y '^mongodb-.*'
sudo apt-get remove -y '^mysql-.*'
sudo apt-get remove -y azure-cli google-cloud-sdk hhvm google-chrome-stable firefox powershell mono-devel
# 自动清理依赖+缓存
sudo apt-get autoremove --purge -y
sudo apt-get autoclean
sudo apt-get clean
df -h
echo "删除大目录"
sudo rm -rf /usr/share/dotnet/
sudo rm -rf /usr/local/graalvm/
sudo rm -rf /usr/local/.ghcup/
sudo rm -rf /usr/local/share/powershell
sudo rm -rf /usr/local/share/chromium
sudo rm -rf /usr/local/lib/android
sudo rm -rf /usr/local/lib/node_modules
sudo rm -rf /usr/share/dotnet
sudo rm -rf /usr/local/lib/android
sudo rm -rf /opt/ghc
sudo rm -rf /usr/local/share/boost
# 清理 Docker
docker system prune -af --volumes
# 删除 GitHub Actions 工具缓存
sudo rm -rf /opt/hostedtoolcache
