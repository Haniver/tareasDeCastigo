import { useRef } from 'react';

function NoCopyInput({ value, onChange, className = '', placeholder = '', ...props }) {
  const inputRef = useRef(null);

  const handlePaste = (e) => {
    e.preventDefault();
  };

  const handleCopy = (e) => {
    e.preventDefault();
  };

  const handleCut = (e) => {
    e.preventDefault();
  };

  const handleDrop = (e) => {
    e.preventDefault();
  };

  const handleContextMenu = (e) => {
    e.preventDefault();
  };

  return (
    <input
      ref={inputRef}
      type="text"
      value={value}
      onChange={(e) => onChange(e.target.value)}
      onPaste={handlePaste}
      onCopy={handleCopy}
      onCut={handleCut}
      onDrop={handleDrop}
      onContextMenu={handleContextMenu}
      className={className}
      placeholder={placeholder}
      autoComplete="off"
      {...props}
    />
  );
}

export default NoCopyInput;
