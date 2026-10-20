'use client';

import React, { useEffect, useState } from 'react';

interface AnimatedPriceCounterProps {
  value: number;
  prefix?: string;
  className?: string;
  decimals?: number;
}

export const AnimatedPriceCounter: React.FC<AnimatedPriceCounterProps> = ({
  value,
  prefix = '₹',
  className = '',
  decimals = 0,
}) => {
  const [displayValue, setDisplayValue] = useState(value);

  useEffect(() => {
    let startTimestamp: number | null = null;
    const startValue = displayValue;
    const endValue = value;
    const duration = 500; // 500ms smooth ticker

    if (startValue === endValue) return;

    const step = (timestamp: number) => {
      if (!startTimestamp) startTimestamp = timestamp;
      const progress = Math.min((timestamp - startTimestamp) / duration, 1);
      // Ease out cubic
      const easeProgress = 1 - Math.pow(1 - progress, 3);
      const current = startValue + (endValue - startValue) * easeProgress;
      
      setDisplayValue(current);

      if (progress < 1) {
        window.requestAnimationFrame(step);
      }
    };

    window.requestAnimationFrame(step);
  }, [value]);

  const formatted = displayValue.toLocaleString('en-IN', {
    minimumFractionDigits: decimals,
    maximumFractionDigits: decimals,
  });

  return (
    <span className={`font-mono-numeric transition-all ${className}`}>
      {prefix}{formatted}
    </span>
  );
};
