import React, { useEffect, useRef } from 'react';
import * as echarts from 'echarts';
import type { PlatformDistribution } from '../../api/dashboard';

interface PlatformDistributionChartProps {
  data: PlatformDistribution[];
}

const PlatformDistributionChart: React.FC<PlatformDistributionChartProps> = ({ data }) => {
  const chartRef = useRef<HTMLDivElement>(null);
  const chartInstance = useRef<echarts.ECharts | null>(null);

  useEffect(() => {
    if (chartRef.current) {
      chartInstance.current = echarts.init(chartRef.current);
    }

    return () => {
      chartInstance.current?.dispose();
    };
  }, []);

  useEffect(() => {
    if (!chartInstance.current || !data || data.length === 0) return;

    const chartData = data.map(item => ({
      value: item.revenue,
      name: item.platform,
    }));

    const option = {
      title: {
        text: '平台分布',
        left: 'center',
      },
      tooltip: {
        trigger: 'item',
        formatter: '{a} <br/>{b}: ¥{c} ({d}%)',
      },
      legend: {
        orient: 'vertical',
        left: 'left',
      },
      series: [
        {
          name: '平台收益',
          type: 'pie',
          radius: '50%',
          data: chartData,
          emphasis: {
            itemStyle: {
              shadowBlur: 10,
              shadowOffsetX: 0,
              shadowColor: 'rgba(0, 0, 0, 0.5)',
            },
          },
          label: {
            formatter: '{b}: {d}%',
          },
        },
      ],
    };

    chartInstance.current.setOption(option);

    const handleResize = () => {
      chartInstance.current?.resize();
    };

    window.addEventListener('resize', handleResize);

    return () => {
      window.removeEventListener('resize', handleResize);
    };
  }, [data]);

  return <div ref={chartRef} style={{ width: '100%', height: '300px' }} />;
};

export default PlatformDistributionChart;
